
var gui = require('nw.gui');
var app = gui.App;
var win = gui.Window.get();
var mb = new gui.Menu({type:"menubar"});

if (process.platform == 'darwin') {
	mb.createMacBuiltin("Ethos");
	win.menu = mb;
}

win.ethos = {test: true};

win.window.location.href = 'http://eth:8080'
