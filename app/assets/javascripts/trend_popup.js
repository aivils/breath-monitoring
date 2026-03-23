(function () {
  function ready(fn) {
    if (document.readyState !== "loading") {
      fn();
    } else {
      document.addEventListener("DOMContentLoaded", fn);
    }
  }

  ready(function () {
    var popup = document.getElementById("trend-popup");
    var openBtn = document.getElementById("trend-open");

    if (!popup || !openBtn) return;

    // open
    openBtn.addEventListener("click", function (e) {
      e.preventDefault();
      popup.style.display = "flex";
      document.body.style.overflow = "hidden";
    });

    // close button
    popup.addEventListener("click", function (e) {
      var closeEl = e.target.closest(".trend-close");

      if (closeEl) {
        e.preventDefault();
        close();
        return;
      }

      // klikšķis uz fona
      if (e.target === popup) {
        close();
      }
    });

    // click outside
    popup.addEventListener("click", function (e) {
      if (e.target === popup) {
        close();
      }
    });

    // ESC
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") {
        close();
      }
    });

    function close() {
      popup.style.display = "none";
      document.body.style.overflow = "";
    }
  });
})();
