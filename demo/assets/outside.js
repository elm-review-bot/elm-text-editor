// OUTSIDE

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

        case "WriteToClipboard":
            console.log("WriteToClipboard", JSON.stringify(msg.data))

            navigator.permissions.query({name: "clipboard-write"}).then(result => {
              if (result.state == "granted" || result.state == "prompt") {
                updateClipboard(JSON.stringify(msg.data))
              }
            });


             break;

         case "Highlight":
           console.log("Highlight", msg.data)
           var id = "#".concat(msg.data)
           console.log("Highlight (2)", id)
           var element = document.querySelector(id)
           if (element != null) {
                 element.classList.add("highlight")
           } else {
                 console.log("Could not find", id)
           }

             // document.querySelector(id).classList.add("highlight") // (2)
             // document.getElementById(id).classList.add("highlight")  // (1)
             // document.querySelector("__rt_scroll__").getElementById(id).classList.add("highlight")


           break;

    }

    function updateClipboard(newClip) {
      navigator.clipboard.writeText(newClip).then(function() {
        console.log("Wrote to clipboard");
      }, function() {
        console.log ("Clipboard write failed");
      });
    }

})


