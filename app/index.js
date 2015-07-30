process.on('uncaughtException', function(){
	alert("uncaught exexption")
})

var gui = require('nw.gui')
var path = require('path')
var spawn = require('child_process').spawn

console.log( "Ethos initializing..." )
gui.Window.get().showDevTools()

var ipfsProcess, ethProcess = null;

function toggleGeth ( ethMenu ) {

	if (ethProcess) {
		kill( ethProcess )
		ethProcess = null;
		return
	}
	var geth_path = path.join( process.cwd(), './bin/win/geth/geth.exe')
	var geth_datadir = path.join( process.cwd(), './eth')

	console.log('Running geth binary')
	console.log( geth_path, geth_datadir )

	var geth = spawn( geth_path, ['--networkid', '1234234', '--datadir', geth_datadir] )

	geth.on('close', function(code){
		alert('Geth Exited with code: ' + code);
		ethMenu.items[0].label = "Status: Disabled"
		ethMenu.items[1].label = "Activate"
		kill( ethProcess )
		ethProcess = null;
	})
	geth.stdout.on('data', function (data) {
		console.log('geth stdout: ' + data);
		ethMenu.items[0].label = "Status: Active"
		ethMenu.items[1].label = "Disable"
	});

	geth.stderr.on('data', function (data) {
		console.log('geth stderr: ' + data);
	});

	ethProcess = geth;

}

function kill (process) {
	console.log("Killing process: ", process )
	process.stdin.pause();
	spawn("taskkill", ["/pid", process.pid, '/f', '/t']);
	process.kill('SIGINT')
}

function toggleIPFS ( ipfsMenu ) {

	if (ipfsProcess) {
		kill( ipfsProcess )
		ipfsProcess = null;
		return
	}

	var ipfs_path = path.join( process.cwd(), './bin/win/ipfs/ipfs.exe')
	var ipfs_datadir = path.join( process.cwd(), './eth')

	console.log('Running ipfs binary')
	console.log( ipfs_path, ipfs_datadir )
		
	var daemon = spawn( ipfs_path, ['daemon', '--init'] )
	daemon.on('close', function(code){
		alert( "IPFS existed with code " + code )
		ipfsMenu.items[0].label = "Status: Disabled"
		ipfsMenu.items[1].label = "Activate"
		kill( ipfsProcess )
		ipfsProcess = null;
	})
	daemon.stdout.on('data', function (data) {
		console.log('ipfs stdout: ' + data);
		ipfsMenu.items[0].label = "Status: Active"
		ipfsMenu.items[1].label = "Disable"
	});

	daemon.stderr.on('data', function (data) {
		console.log('ipfs stderr: ' + data);
	});

	ipfsProcess = daemon;
}



onload = function(){
	
	var menu = new gui.Menu();
	var ipfsMenu = new gui.Menu()
	var ethMenu = new gui.Menu()

	var tray = new gui.Tray({
		title: "Ethos",
		icon: "./app/images/icon-tray.png",
		menu: menu
	})

	var title = new gui.MenuItem({
		label: 'Ethos',
		enabled: false
	})
	
	var quit = new gui.MenuItem({
		label: 'Quit',
		key: 'q',
		modifiers: 'ctrl-alt',
		click: function(){
			tray.remove()
			process.exit(0);
		}
	})

	var about = new gui.MenuItem({
		label: 'About',
		click: function(){
			gui.Shell.openExternal('http://localhost:8080/ipfs/ethosAbout');
		}
	})

	var debug = new gui.MenuItem({
		label: 'Debug',
		click: function(){
			gui.Window.get().showDevTools()
		}
	})

	var ipfs = new gui.MenuItem({
		label: 'IPFS',
		submenu: ipfsMenu
	})

	var eth = new gui.MenuItem({
		label: 'Ethereum',
		submenu: ethMenu
	})

	ipfsStatus = new gui.MenuItem({
		label: 'Status: Disabled',
		enabled: false
	})

	ipfsToggle = new gui.MenuItem({
		label: 'Activate',
		click: function(){ toggleIPFS( ipfsMenu ) }
	})

	ethStatus = new gui.MenuItem({
		label: 'Status: Disabled',
		enabled: false
	})

	ethToggle = new gui.MenuItem({
		label: 'Activate',
		click: function(){ toggleGeth( ethMenu ) }
	})


	ipfsMenu.append( ipfsStatus )
	ipfsMenu.append( ipfsToggle )
	
	ethMenu.append( ethStatus )
	ethMenu.append( ethToggle )

	menu.append( title )
	menu.append( about )
	menu.append( ipfs )
	menu.append( eth )
	menu.append( debug )
	menu.append( quit )

	toggleGeth( ethMenu )
	toggleIPFS( ipfsMenu )

	
}