// OUTSIDE

navigator.permissions.query({
  name: 'clipboard-read'
}).then(permissionStatus => {
  // Will be 'granted', 'denied' or 'prompt':
  console.log(permissionStatus.state);
  // setup app ports here ...
  // Listen for changes to the permission state

        app.ports.infoForOutside.subscribe(msg => {

            console.log("app.ports.infoForOutside")

            switch(msg.tag) {

                case "AskForClipBoard":
                console.log("AskForClipBoard")
                navigator.clipboard.readText()
                  .then(text => {
                    console.log('Clipboard (outside):', text);
                    app.ports.infoForElm.send({tag: "GotClipboard", data:  text})
                  })
                  .catch(err => {
                    console.error('Failed to read clipboard: ', err);
                  });

                break;

            }

        })

  permissionStatus.onchange = () => {
    console.log(permissionStatus.state);
    // remove app ports if permission is revoked ...
  };
});





