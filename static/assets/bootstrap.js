console.log( 'Bootstraping Ethos from app://<root>/bootstrap.html' )
console.log( "This: ", this );
console.log( "[Window, Global]:", [typeof window !== 'undefined', typeof global !== 'undefined'] );

if (typeof require !== 'undefined') {
	console.log( 'Require: ', typeof require )
}



if (typeof global !== 'undefined') {
	try {
		var gui = require('nw.gui');
	} catch (err) {
		console.log( "Error: ", err );
	}
	var app = gui.App;
	var win = gui.Window.get();
	var mb = new gui.Menu({type:"menubar"});

	// document.addEventListener( 'keyup', function (e) {
	// 	if (e.keyCode == 'O'.charCodeAt(0) and e.ctrlKey) console.log('open')
	// 	else if (e.keyCode == 'S'.charCodeAt(0) and e.ctrlKey) console.log('save')
	// });

	if (process.platform == 'darwin') {
		mb.createMacBuiltin("Ethos");
		win.menu = mb;
	}

	win.ethos = {test: true};

	win.window.location.href = 'http://eth:8080/'


	win.onerror = function(){ alert('err') }
}

console.log( 'Ethos Bootstrap end: ok.' )