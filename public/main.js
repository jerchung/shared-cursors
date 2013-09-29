(function() {
  var ID;
  var CONNECTED = false;

  $(document).ready(function() {
    var ws = new WebSocket("ws://localhost:8080");
    ws.onmessage = function(msg) {
      handleMessage(msg.data);
    };

    $(document).mousemove(function(evt) {
      console.log("x:" + evt.pageX);
      console.log("y:" + evt.pageY);
      var update = {type: "update", id: ID, x: evt.pageX, y: evt.pageY};
      ws.send(JSON.stringify(update));
    });

  });

  function handleMessage(msg) {
    var parsedMsg = JSON.parse(msg);

    switch(parsedMsg.type) {
      case "new":
        ID = parsedMsg.id;
        CONNECTED = true;
        break;
      case "create":
        if (ID !== null && ID !== parsedMsg.id) {
          createCursor(parsedMsg);
        }
        break;
      case "update":
        if (parsedMsg.id != ID) {
          updateCursor(parsedMsg.id, parsedMsg.x, parsedMsg.y);
        }
        break;
      case "del":
        removeCursor(parsedMsg.id);
        break;
      default:
        console.log("Errrorrr");
    }
  }

  function createCursor(msg) {
    var newDiv = "<div id='cursor" + msg.id + "' class='cursor'></div>";
    $("#body").append(newDiv);
    $("#cursor" + msg.id).css({x: msg.x, y: msg.y, display: msg.display});
  }

  function updateCursor(id, x, y) {
    $("#cursor" + id).css({left: x, top: y, display: "block"});
  }

  function removeCursor(id) {
    $("#cursor" + id).remove();
  }


})();