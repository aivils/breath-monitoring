/*jshint esversion: 6 */
const { el, mount, setChildren} = redom

function nstr(n) {
  return ((n<10)?'0':'') + n;
}

function hhmmss(secs) {
  if (secs >= (3600)) {
    let rsecs = secs % 3600;
    return nstr(Math.floor(secs/3600)) + ':' + nstr(Math.floor(rsecs/60)) + ':' + nstr(rsecs%60);
  } else if (secs >= 60) {
    return nstr(Math.floor(secs/60)) + ':' + nstr(secs%60);
  } else {
    return nstr(secs);
  }
}

function mkfname(duration,prefix) {
  let now = new Date();
  let mm = now.getMonth() + 1;
  var dd = now.getDate();
  return 'brmon-' + (prefix || '') + now.getFullYear() +
    nstr(now.getMonth() + 1) +
    nstr(now.getDate()) +
    nstr(now.getHours()) +
    nstr(now.getMinutes()) +
    nstr(now.getSeconds()) +
    '-' + duration + '.txt';
}

function saveToFile(data, fileName, type) {
  type = type || 'application/octect-stream';
  let a = document.createElement("a");
  let url = URL.createObjectURL(new Blob([data], {type: type}));
  a.href = url;
  a.download = fileName;
  document.body.appendChild(a);
  a.click();
  setTimeout(function() {
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
  }, 0);
}

const csrfToken = () => {
  if (typeof document != 'undefined') {
    const metaTag = document.querySelector('meta[name=csrf-token]');
    if (metaTag) {
      return metaTag.getAttribute('content');
    }
  }

  return null;
};

function saveToServer(data, savePath, code) {
  const formData = new FormData();
  const file = new Blob([data], {type: 'plain/text'});
  formData.append('measurement[data_file]', file, 'data.txt');
  formData.append('measurement[code]', code);
  formData.append('authenticity_token', csrfToken());
  formData.append('format', 'json');
  return fetch(savePath, {
    method: 'POST',
    body: formData,
    headers: {
      'Accept': 'application/json, text/plain, */*',
    }
  })
  .then(response => response.json());
}

class Overlay {
  constructor(options) {
    //note: parent-position-should-be-relative-then child-absolute - makes child fixed relative to parent
    this.options = options;
    if (options.x == null) { this.options.x = 0; }
    if (options.y == null) { this.options.y = 0; }
    if (options.w == null) { this.options.w = 75; }
    if (options.h == null) { this.options.h = 75; }
    this.moveResizeEl = options.moveResizeEl;
    this.onMove = options.onMove;
    this.onResize = options.onResize;
    //note: default display is none
    this.el = el('.absolute.flex.ba.bw1.b--green.pointer.w3.h3',
      {style:{resize:'both', draggable:true, overflow:'auto', display:'none'}},
    )
    this.ro = new ResizeObserver(this.resize).observe(this.el);
    this.el.addEventListener('mousedown', this.moveStart, false);
    if ('ontouchstart' in window) {
      this.el.addEventListener('touchstart', this.moveStart, false);
    }
  }
  onmount() {
    //console.log('Overlay.onmount', this.options);
    this.el.style.width = this.options.w + 'px';
    this.el.style.height = this.options.h + 'px';
    this.el.style.left = this.options.x + 'px';
    this.el.style.top = this.options.y + 'px';
  }
  //note: resize occurs automatically due to ResizeObserver - and onmount of parent needs to set initial size not here
  resize = (evt) => {
    //use computedStyle cuz. default style is empty until click/interaction with page
    let cs = getComputedStyle(this.el);
    if (this.moveResizeEl) {
      if (this.moveResizeEl.style.width != cs.width) {
        this.moveResizeEl.style.width = cs.width;
        this.moveResizeEl.style.height = cs.height;
        //resize requires move also
        this.moveResizeEl.style.left = cs.left;
        this.moveResizeEl.style.top = cs.top;
      }
    }
    if (this.onResize) {
      this.onResize({width:parseInt(cs.width), height:parseInt(cs.height)});
    }
    //resize requires move also
    if (this.onMove) {
      this.onMove({x:parseInt(cs.left), y:parseInt(cs.top)});
    }
  }
  moveStart = (evt) => {
    let evtX, evtY, evtMove, evtStop;
    if (evt.touches) {
      evtX = evt.touches[0].pageX;
      evtY = evt.touches[0].pageY;
      evtMove = 'touchmove';
      evtStop = 'touchend';
    } else {
      evtX = evt.clientX;
      evtY = evt.clientY;
      evtMove = 'mousemove';
      evtStop = 'mouseup';
    }
    //if resize-handle allow browser to do its thing
    let r = this.el.getBoundingClientRect();
    if (((r.right - evtX) <= 12) &&
        ((r.bottom - evtY) <= 12)) {
      return false;
    }
    evt.preventDefault();
    this.startX = evtX;
    this.startY = evtY;
    this.el.addEventListener(evtStop, this.moveStop, false);
    this.el.addEventListener(evtMove, this.moveEl, false);
  }
  moveStop = (evt) => {
    let evtMove, evtStop;
    if (evt.touches) {
      evtMove = 'touchmove';
      evtStop = 'touchend';
    } else {
      evtMove = 'mousemove';
      evtStop = 'mouseup';
    }
    this.el.removeEventListener(evtStop, this.moveStop, false);
    this.el.removeEventListener(evtMove, this.moveEl, false);
  }
  moveEl = (evt) => {
    let evtX, evtY;
    if (evt.touches) {
      evtX = evt.touches[0].pageX;
      evtY = evt.touches[0].pageY;
    } else {
      evtX = evt.clientX;
      evtY = evt.clientY;
    }
    let x = this.startX - evtX;
    let y = this.startY - evtY;
    this.el.style.left = (this.el.offsetLeft - x) + 'px';
    this.el.style.top = (this.el.offsetTop - y) + 'px';
    this.startX = evtX;
    this.startY = evtY;
    if (this.moveResizeEl) {
      this.moveResizeEl.style.left = this.el.style.left;
      this.moveResizeEl.style.top = this.el.style.top;
    }
    //note: maybe can save some cpu-cycles by doing this after (in moveStop) instead of during - this is more responsive and similar to ResizeObserver
    if (this.onMove) {
      this.onMove({x:parseInt(this.el.style.left), y:parseInt(this.el.style.top)});
    }
  }
  stateAlert = () => {
    this.el.classList.remove("b--green");
    this.el.classList.add("b--red");
  }
  stateNormal = () => {
    this.el.classList.add("b--green");
    this.el.classList.remove("b--red");
  }
}

class VideoCap0 {
  constructor(options) {
    this.options = options;
    this.el = el('.relative.flex.justify-center.items-center', [
      this.elGraph = el('canvas.absolute.self-start.w-100.h3.bg-green.o-50'),
      this.elVideo = el('video.bg-yellow'),
      this.elOverlayCanvas = el('canvas.absolute.w5.h5.bg-red'),
      this.elOverlay = new Overlay(this.elCanvas),
      el('.absolute.self-start.sans-serif.f3.pa1.bg-blue.white.flex.flex-row', [
        this.elStart = el('.pointer', 'Start'),
        this.elSave = el('.pointer', 'Save')
      ]),
    ]);
  }
}

class VideoCap {
  constructor(options) {
    //console.log('VideoCap', options);
    this.options = options;
    this.el = el('.relative.flex.justify-center.items-center', [
      this.elShowCode = el('.absolute', {style: {display: 'none', "min-width": '200px', top: '-30px'}}),
      this.elVideo = el('video', {controls:true, style:{display:'none'}}),
      //this.elVideo = el('video', {src:'test.mkv', style:{display:'none'}}),
      this.elGraph = el('canvas.absolute.self-start.w-100.h3.bg-black.o-70', {style:{display:'none'}}),
      //note: not hiding Overlay/Canvas as initial size/position goes for a toss then
      this.elOverlayCanvas = el('canvas.absolute'),
      this.elOverlay = new Overlay({
        moveResizeEl: this.elOverlayCanvas,
        x:this.options.x,
        y:this.options.y,
        w:this.options.w,
        h:this.options.h,
        onMove: this.overlayMove,
        onResize: this.overlayResize}),
      this.topBar = el('.absolute.self-start.sans-serif.f5.pa1.bg-orange.white', {style:{display:'none'}},
        [this.elStatus = el('span.pointer.ba'),
         this.elPause = el('span.pointer.ba.ml2', {style:{display:'none'}}, 'Pause'),
         this.elSave = el('span.pointer.ba', {style:{display:'none'}}, 'Save'),
         this.elSucess = el('span.pointer.ba', {style:{display:'none'}}, 'Successfully uploaded'),
         this.elError = el('span.pointer.ba.bg-red', {style:{display:'none'}}),
      ]),
      el('#videoInput.absolute',[
        // this.elFile = el('input', {type:'file', accept: 'video/*'}),
        this.elCodeForm = el('form.w-100', {style: {"min-width": '200px'}}, [
          el('label', {}, 'Code:'),
          this.elCode = el('input', {type: 'text', name: 'code',
            pattern: '[_a-zA-Z0-9]+', required: true, placeholder: 'Enter the code',
            title: "Only numbers, letters and underscore are allowed !"}),
          el('input.ma1', {type: 'submit', value: 'Submit'})
        ]),
        this.elSelectVideoDevice = el('select', {style:{display:'none'}})
      ])
    ]);
    this.firstVideoTime = null;
    this.lastVideoTime = 0;
    this.lastFrameTime = 0;
    this.frameInterval = Math.round(1000 / this.options.fps);
    this.data = [];
    this.fdata = [];

    this.elVideo.addEventListener('loadedmetadata',this.videoLoadedMetaData,false);
    this.elVideo.addEventListener('play',this.videoPlay,false);
    this.elVideo.addEventListener('pause',this.videoPause,false);
    this.elVideo.addEventListener('ended',this.videoEnded,false);
    this.elSave.addEventListener('click',this.saveClick,false);
    // this.elFile.addEventListener('change', this.fileChange, false);
    this.elPause.addEventListener('click', this.togglePause);
    this.elCodeForm.addEventListener('submit', this.handleSubmitCodeForm);
    this.modeGraphAfterSave = this.options.recordMode == 'graph_after_save';
  }
  onmount() {
    //console.log('VideoCap.onmount');
    navigator.mediaDevices.enumerateDevices().then((devices) => {
      let devlist = [el('option', 'Select Camera')];
      devices.filter((d) => d.kind === 'videoinput').forEach((k,i) => {
        devlist.push(el('option', {'value':k.deviceId}, (k.label || 'videoinput-'+i)));
      });
      if (devlist.length > 1) {
        this.elSelectVideoDevice.addEventListener('input',this.selectVideoDevice,false);
        setChildren(this.elSelectVideoDevice, devlist);
        // this.elSelectVideoDevice.style.display = 'block';
      }
    });
  }
  videoOpen = (stream) => {
    //console.log('onVideoOpen');
    this.elVideo.style.display = 'block';
    this.elVideo.srcObject = stream;
    this.elVideo.play();
  }
  videoError = (err) => {
    this.elStatus.innerText = err.name + ': Allow access to camera, and try again.';
  }
  selectVideoDevice = (evt) => {
    //console.log('selectVideoDevice', this.elSelectVideoDevice.value, evt);
    if (this.elSelectVideoDevice.value != 'Select Camera') {
      navigator.mediaDevices.getUserMedia({
          'audio':false,
          'video':{'deviceId': this.elSelectVideoDevice.value}
      }).then(this.videoOpen).catch(this.videoError);
      //no need for elSelectVideoDevice anymore
      this.elSelectVideoDevice.style.display = 'none';
      this.elSelectVideoDevice.removeEventListener('input',this.selectVideoDevice,false);
      /*
      this.elFile.style.display = 'none';
      this.elFile.removeEventListener('change', this.fileChange, false);
      */
    }
  }
  fileChange = (evt) => {
    //console.log('fileChange', evt);
    if (!this.elVideo.canPlayType(this.elFile.files[0].type)) {
      console.log('ERR playing ', this.elFile.files[0].name);
      return;
    }
    this.elVideo.src = URL.createObjectURL(this.elFile.files[0]);
    this.elFile.style.display = 'none';
    this.elFile.removeEventListener('change', this.fileChange, false);
    this.elSelectVideoDevice.style.display = 'none';
    this.elSelectVideoDevice.removeEventListener('input',this.selectVideoDevice,false);
  }
  videoLoadedMetaData = (evt) => {
    //console.log('videoLoadedMetaData');
    //this.elVideo.controls = true;
    document.getElementById("measure-title").style.display = 'none';
    this.elVideo.style.width = '100%';
    // this.elVideo.style.height = 'auto';
    this.videoScaleX = this.elVideo.clientWidth / this.elVideo.videoWidth;
    this.videoScaleY = this.elVideo.clientHeight / this.elVideo.videoHeight;
    const offsetLeft = Math.floor(this.elVideo.clientWidth/2 - this.options.w/2);
    const offsetTop = Math.floor(this.elVideo.clientHeight/2 - this.options.h/2);
    this.elOverlay.el.style.left = offsetLeft + 'px';
    this.elOverlay.el.style.top = offsetTop + 'px';
    this.elVideo.style.display = 'block';
    this.elOverlayCanvas.style.display = 'block';
    this.elOverlay.el.style.display = 'block';
    this.elGraph.style.display = 'block';
    this.topBar.style.display = 'initial';
    this.elPause.style.display = 'initial';
    //cant do this in mount as display is none
    this.overlayX = this.elOverlay.el.offsetLeft;
    this.overlayY = this.elOverlay.el.offsetTop;
    this.elOverlayCanvas.style.left = this.overlayX + 'px';
    this.elOverlayCanvas.style.top = this.overlayY + 'px';
    //since canvas width/height are set style.width/height is not needed
  }
  videoPlay = (evt) => {
    //this.elStatus.innerText = 'Capturing...';
    this.elSave.style.display = 'none';
    this.firstVideoTime = null;
    this.lastVideoTime = 0;
    this.lastFrameTime = 0;
    this.fdata = [];
    this.data = [];
    this.elPause.textContent = 'Pause';
    //note: video.timeupdate is not deterministic - requestAnimationFrame is better
    this.rafID = requestAnimationFrame(this.onFrame.bind(this));
  }
  videoPause = (evt) => {
    //this.elStatus.innerText = 'Paused.';
    cancelAnimationFrame(this.rafID);
    this.elVideo.currentTime = 0;
    this.elPause.textContent = 'Start';
    this.elSave.style.display = 'block';
  }
  videoEnded = (evt) => {
    //console.log('videoEnded');
    cancelAnimationFrame(this.rafID);
    this.elSave.style.display = 'block';
  }
  saveClick = (evt) => {
    this.handleSave({});
  }
  stopStream = () => {
    this.elVideo.srcObject.getTracks().forEach(function(track) {
      if (track.readyState == 'live') {
        track.stop();
      }
    });
  }
  handleSave = (saveOptions) => {
    //console.log('pndng.save');
    if (this.fdata && this.fdata.length > 0) {
      /*saveToFile(this.fdata.join('\n'),
                 mkfname(Math.round(this.elVideo.currentTime), this.gsize+'-'),
                 'text/plain');*/
      saveToServer(this.fdata.join('\n'), this.options.savePath, this.elCode.value)
      .then((res) => {
        if (res.id) {
          this.elSave.style.display = 'none';
          this.elSucess.style.display = 'block';
          setTimeout(() => {
            this.elSucess.style.display = 'none';
          }, 5000);
          if (this.modeGraphAfterSave) {
            this.stopStream();
            document.getElementById('video-container').style.display = 'none';
            window.UserGraph.init({
              data: this.fdata,
              recordLength: this.options.recordLength,
              recordDataWindowLength: this.options.recordDataWindowLength,
              measurementId: res.id,
              savePath: this.options.savePath
            });
          }
        } else {
          this.elError.style.display = 'block';
          this.elError.textContent = JSON.stringify(res.errors);
        }
      }).catch((err) => {
        this.elError.style.display = 'block';
        this.elError.textContent = `Save failed: ${JSON.stringify(err)}`;
      });
    }
  }
  overlayResize = (evt) => {
    //console.log('overlayResize', evt);
    this.elOverlayCanvas.width = evt.width;
    this.elOverlayCanvas.height = evt.height;
    this.gsize = evt.width * evt.height;
  }
  overlayMove = (evt) => {
    //console.log('overlayMove', evt);
    this.overlayX = evt.x;
    this.overlayY = evt.y;
  }
  updateGraph = (value) => {
    if (!this.ctxGraph) {
      this.ctxGraph = this.elGraph.getContext('2d');
      this.ctxGraph.width = this.elGraph.clientWidth;
      this.ctxGraph.height = this.elGraph.clientHeight;
    }
    const w = this.elGraph.clientWidth;
    const h = this.elGraph.clientHeight;
    const ctx = this.ctxGraph;

    this.data.push(value);

    //can graph only graph-width-pixels - so slice data
    let data = this.data.slice(-1*w);
    //let data = this.data.slice(-10*this.options.fps); //10 fps worth of data
    const n = data.length;
    ctx.clearRect(0, 0, w, h);
    ctx.lineWidth = 2;
    ctx.strokeStyle = 'blue';
    ctx.beginPath();
    data.forEach((val, i) => {
      ctx.lineTo(i*w/n, h*val);
    });
    ctx.stroke();
  }
  onFrame(timestamp) {
    //console.log('onFrame', timestamp);
    //if no processing is done - this would be about 60 fps
    if ((this.elVideo.readyState === this.elVideo.HAVE_ENOUGH_DATA) &&
        (!this.elVideo.paused) && (!this.elVideo.ended) &&
        (this.elVideo.currentTime >= this.lastVideoTime)) {

      /*if (this.lastFrameTime > 0) {
        let duration = (this.elVideo.currentTime - this.lastFrameTime);
        //this.elStatus.innerText = Math.round(1/duration) + ' fps '; //.toFixed(2)
      }*/
      this.lastVideoTime = this.elVideo.currentTime;

      //do conversion as fast as possible - doing it @fps provides stuttering ux
      const ctxOverlay = this.elOverlayCanvas.getContext('2d');
      // Draw selected area of video to OffScreenCanvas
      ctxOverlay.drawImage(this.elVideo,
        this.overlayX / this.videoScaleX, this.overlayY / this.videoScaleY,
        this.elOverlayCanvas.width / this.videoScaleX, this.elOverlayCanvas.height / this.videoScaleY,
        0, 0,
        this.elOverlayCanvas.width, this.elOverlayCanvas.height);

      const calculateGrayscale = (rgba) => {
        // grayscale magic-numbers change as reqd.
        //from http://www.poynton.com/notes/colour_and_gamma/ColorFAQ.html
        //const rgb2gs = [0.2125, 0.7154, 0.0721];
        const rgb2gs = [0.299, 0.587, 0.114];
        let gcount = 0;
        for (let i = 0; i < rgba.data.length; i += 4) {
          let mono = (rgba.data[i] * rgb2gs[0]) + (rgba.data[i+1] * rgb2gs[1]) + (rgba.data[i+1] * rgb2gs[2]);
          //convert mono into bw and count white pixels
          if (mono < this.options.gmax) {
            gcount++;
            mono = 0;
          } else {
            mono = 255;
          }
          rgba.data[i] = mono;
          rgba.data[i+1] = mono;
          rgba.data[i+2] = mono;
        }
        return gcount;
      }
      const halfHeight = Math.round(this.elOverlayCanvas.height/2);
      const upperRgba = ctxOverlay.getImageData(0, 0, this.elOverlayCanvas.width, halfHeight);
      const upperGcount = calculateGrayscale(upperRgba);
      const lowerRgba = ctxOverlay.getImageData(0, halfHeight, this.elOverlayCanvas.width, halfHeight);
      const lowerGcount = calculateGrayscale(lowerRgba);
      // get the imageData from OffScreenCanvas
      const rgba = ctxOverlay.getImageData(0, 0, this.elOverlayCanvas.width, this.elOverlayCanvas.height);
      const gcount = calculateGrayscale(rgba);
      if (upperGcount > lowerGcount) {
        this.elOverlay.stateAlert();
      } else {
        this.elOverlay.stateNormal();
      }

      // draw modified Image on overlayCanvas
      ctxOverlay.putImageData(rgba, 0, 0);

      let now = new Date().getTime();
      if (!this.firstVideoTime) {
        this.firstVideoTime = now;
      }
      //fps is for graph updata only
      if ((now - this.lastFrameTime) >= this.frameInterval) {
        const normalized =  Math.round((1 - gcount/this.gsize) * 100000) / 100000;
        this.lastFrameTime = now;
        const elapsedTime = (now - this.firstVideoTime) / 1000 /* seconds */
        this.fdata.push(elapsedTime + ' ' + normalized);
        this.updateGraph(normalized); //% of overlaypixels
        this.elStatus.innerText = hhmmss(Math.round(elapsedTime));
        BreathMonit.send({t: elapsedTime, c: normalized});

        if (this.modeGraphAfterSave && elapsedTime >= this.options.recordLength) {
          this.elVideo.pause();
          this.handleSave({});
        }
      }

    //} else {
      //console.log('skip', this.elVideo.readyState, this.elVideo.HAVE_ENOUGH_DATA, this.elVideo.paused, this.elVideo.ended, this.elVideo.currentTime, this.lastFrameTime);
    }
    //repeat until videoPause or videoEnded
    this.rafID = requestAnimationFrame(this.onFrame.bind(this));
  }

  togglePause = (evt) => {
    if (this.elVideo.paused) {
      this.elVideo.play();
    } else {
      this.elVideo.pause();
    }
  }

  handleSubmitCodeForm = (evt) => {
    evt.preventDefault();
    this.elShowCode.textContent = `Code: ${this.elCode.value}`;
    this.elShowCode.style.display = 'block';
    this.elCodeForm.style.display = 'none';
    if (this.elSelectVideoDevice.children.length > 0) {
      this.elSelectVideoDevice.style.display = 'block';
    }
    return false;
  }
}


class App {
  constructor(options) {
    if (navigator.mediaDevices /* && navigator.getUserMedia && window.MediaRecorder */) {

      let urlParams = new URLSearchParams(window.location.search);
      let x = parseInt(urlParams.get('x') || '0') || 0;
      let y = parseInt(urlParams.get('y') || '0') || 0;
      let w = parseInt(urlParams.get('w') || '20') || 20;
      let h = parseInt(urlParams.get('h') || '75') || 75;
      if (x < 0) { x = 0 };
      if (y < 0) { y = 0 };
      if (w <= 0) {
        w = (h > 0) ? h : 0;
      }
      if (h <= 0) {
        h = (w > 0) ? w : 0;
      }
      let fps = parseInt(urlParams.get('fps') || '15') || 15;
      fps = ((fps > 0) && (fps <= 30)) ? fps : 15;
      let gmax = parseInt(urlParams.get('gmax') || '126') || 126;
      gmax = ((gmax >= 0) && (gmax <= 255)) ? gmax : 126;

      this.el = el('#app.w-100.h-100.flex.justify-center.items-center',
        this.videocap = new VideoCap({x:x, y:y, w:w, h:h, fps:fps, gmax:gmax,
          savePath: options.savePath, recordMode: options.recordMode,
          recordLength: options.recordLength,
          recordDataWindowLength: options.recordDataWindowLength,
        })
      );
    } else {
      this.el = el('p.bg-yellow.w-100.h-100.flex.justify-center.items-center', 'Supported/Tested browsers are Google Chrome 79+ or iOS Safari');
    }
  }
}

