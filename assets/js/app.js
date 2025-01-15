// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Cropper from "cropperjs";
let Hooks = {};

Hooks.Cropper = {
    mounted() {
        document.addEventListener("DOMContentLoaded", function () {
            // Select the file input
            const fileInput = document.querySelector(".file-input");
            const previewDiv = document.querySelector(".live-preview-div");
            const cropButton = document.getElementById("btn-crop");
            const outputImage = document.getElementById("output");
          
            // Listen for changes to the file input
            fileInput.addEventListener("change", function () {
              // Wait for the image to be previewed
              const imageSrc = previewDiv.querySelector("img") ? previewDiv.querySelector("img").src : null;
          
              // If an image exists in the preview, enable the crop button
              if (imageSrc) {
                cropButton.disabled = false;
              } else {
                cropButton.disabled = true;
              }
            });
          
            // Add event listener for cropping
            if (cropButton) {
              cropButton.addEventListener("click", function () {
                const cropper = new Cropper(previewDiv, { aspectRatio: 1 });
                var croppedImage = cropper.getCroppedCanvas().toDataURL();
                outputImage.src = croppedImage;
                document.querySelector('.cropped-container').style.display = "flex";
              });
            }
          });
          
        
    }

}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())
let liveSocket = new LiveSocket("/live", Socket, {
    hooks: Hooks,
    params: { _csrf_token: csrfToken },
});
// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

