class VoiceControl {
  constructor(options) {
    this.validStartWords = ['ok', 'okay', 'hockey'];
    this.VideoCap = options.VideoCap;
    this.onstart = this.onstart.bind(this);
    this.onspeechend = this.onspeechend.bind(this);
    this.onresult = this.onresult.bind(this);
    this.startRecognition();
  }

  startRecognition() {
    if (this.recognition && this.recognition.stop) {
      this.recognition.stop();
    }
    var SpeechRecognition = SpeechRecognition || webkitSpeechRecognition;
    this.recognition = new SpeechRecognition();
    this.recognition.onstart = this.onstart;
    this.recognition.onspeechend = this.onspeechend;
    this.recognition.onresult = this.onresult;
    this.recognition.start();
  }

  onstart() {
    console.log("VoiceControl are listening. Try speaking into the microphone.");
  }

  onspeechend() {
    this.startRecognition();
  }

  onresult(evt) {
    var transcript = evt.results[0][0].transcript;
    var confidence = evt.results[0][0].confidence;
    console.log(`recognized='${transcript}' confidence=${confidence}`);
    if (this.validStartWords.indexOf(transcript) >= 0) {
      this.VideoCap.videoPlay({});
    }
  };
}

