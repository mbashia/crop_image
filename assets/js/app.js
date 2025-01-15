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
let Hooks = {};

Hooks.Cropper = {
  mounted() {
    console.log("cropper image mounted");
  
    // Wait for the image element to load
    const waitForImage = () => {
      const imgElement = document.getElementById("image-to-crop");
      if (!imgElement) {
        console.log("Image element not found, retrying...");
        setTimeout(waitForImage, 100); // Retry every 100ms
        return;
      }
  
      console.log("Image element found:", imgElement);
  
      // Ensure cross-origin attribute is set
      imgElement.setAttribute("crossOrigin", "anonymous");
  
      // Initialize Cropper when the image is ready
      imgElement.addEventListener("load", () => {
        console.log("Image loaded, initializing Cropper...");
        let cropper = new Cropper(imgElement, {
          dragMode: "move",
          aspectRatio: 16 / 9,
          autoCropArea: 0.65,
          restore: false,
          guides: false,
          center: false,
          highlight: false,
          cropBoxMovable: false,
          cropBoxResizable: false,
          toggleDragModeOnDblclick: false,
          ready() {
            console.log("Cropper initialized successfully:", cropper);
          },
        });
  
        // Optional: Add a button to crop the image
        const cropButton = document.getElementById("crop-button");
        if (cropButton) {
          cropButton.addEventListener("click", () => {
            if (!cropper) {
              console.error("Cropper is not initialized.");
              return;
            }
  
            const croppedCanvas = cropper.getCroppedCanvas();
            if (!croppedCanvas) {
              console.error("Failed to get cropped canvas.");
            }
  
            croppedCanvas.toBlob((blob) => {
              if (!blob) {
                console.error("Failed to convert cropped canvas to Blob.");
                return;
              }
  
              blobToBase64(blob)
                .then((base64) => {
                  console.log("Cropped image as Base64:", base64);
                  // Push the cropped image to the server or LiveView
                  this.pushEvent("upload_cropped_image", {
                    cropped_image: base64,
                  });
                })
                .catch((error) => {
                  console.error("Error converting blob to Base64:", error);
                });
            }, "image/jpeg");
          });
        }
      });
    };
  
    waitForImage();
  
    // Utility to convert Blob to Base64
    function blobToBase64(blob) {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result);
        reader.onerror = reject;
        reader.readAsDataURL(blob);
      });
    }
  },
  


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

