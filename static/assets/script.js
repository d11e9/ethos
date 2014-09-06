
var gui = require('nw.gui');
var app = gui.App;
var win = gui.Window.get();

win.on( 'document-end', function(frame){
  if (frame) {
  	console.log( 'document-end', arguments)
  	win.eval( frame, 'console.log("inject eth object");' )
  }
})

