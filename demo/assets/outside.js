// OUTSIDE

app.ports.infoForOutside.subscribe(msg => {

    console.log("app.ports.infoForOutside")

    switch(msg.tag) {

        case "AskForClipBoard":
        console.log("AskForClipBoard")

//        navigator.permissions.query({name:'clipboard'}).then(function(result) {
//         if (result.state == 'granted') {
//           console.log('Permission  to access clipboard granted');


        navigator.clipboard.readText()
          .then(text => {
            console.log('Clipboard (outside):', text);
            app.ports.infoForElm.send({tag: "GotClipboard", data:  text})
          })
          .catch(err => {
            console.error('Failed to read clipboard: ', err);
          });


//         } else if (result.state == 'prompt') {
//           alert('Browser is asking for permission');
//         }
//         // Don't do anything if the permission was denied.
//        });

        break;

    }

})


