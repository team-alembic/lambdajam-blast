// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import LiveSocket from "phoenix_live_view";

let liveSocket = new LiveSocket("/live");
liveSocket.connect();

// The following is a hack to play audio.
// We observe DOM element creation events underneath the element with ID "sound-fx".
// Those nodes have attributes that describe the audio file to play.
window.initSFX = function() {
  const soundFiles = [
    "/sfx/fighter-die.wav",
    "/sfx/fighter-powerup.wav",
    "/sfx/fighter-shields-up-loop.wav",
    "/sfx/fighter-shoot.wav"
  ];

  const context = new AudioContext();

  function decode(name, response) {
    return response.arrayBuffer().then(arrayBuffer =>
      context.decodeAudioData(arrayBuffer).then(buffer => ({
        name,
        buffer
      }))
    );
  }

  Promise.all(
    soundFiles.map(name => fetch(name).then(response => decode(name, response)))
  )
    .then(fetched => {
      console.log({ fetched });
      return fetched.reduce(
        (acc, { name, buffer }) => ({ ...acc, [name]: buffer }),
        {}
      );
    })
    .then(files => {
      const targetNode = document.getElementById("sound-fx");
      const config = { childList: true, subtree: true };
      const callback = function(mutationsList) {
        for (const mutation of mutationsList) {
          if (mutation.type == "childList") {
            mutation.addedNodes.forEach(node => {
              const source = context.createBufferSource();
              source.buffer = files[node.getAttribute("data-src")];
              source.connect(context.destination);
              source.start(0);
            });
          }
        }
      };
      const observer = new MutationObserver(callback);
      observer.observe(targetNode, config);
    });
};
