process.on('uncaughtException', function(){
	alert("uncaught exexption")
})

var gui = require('nw.gui')
var path = require('path')
var web3 = require('web3')
var auto_launch = require('auto-launch')
var spawn = require('child_process').spawn

console.log( "Ξthos initializing..." )

var ipfsProcess, ethProcess = null;


web3.connect = function(ethMenu){
	var tries = 0;
	var connect = function(){
		try {
			web3.setProvider( new web3.providers.HttpProvider('http://localhost:8545') )
			console.log( "Ethereum coinbase: ", web3.eth.coinbase )
			console.log( "Ethereum accounts: ", web3.eth.accounts )
		} catch (error) {
			console.log( "Error connecting to local Ethereum node" )
			console.log( error )
			tries++;
			if (tries < 10) setTimeout(connect, 100); 
		}
	}
	setTimeout(connect, 100);
}

function toggleGeth ( ethMenu ) {

	if (ethProcess) {
		kill( ethProcess )
		ethProcess = null;
		return
	}
	var geth_path = path.join( process.cwd(), './bin/win/geth/geth.exe')
	var geth_datadir = path.join( process.cwd(), './eth')
	var geth_genesis_block = path.join( process.cwd(), './eth', 'genesis_block.json')

	console.log('Running geth binary')
	console.log( geth_path, geth_datadir, geth_genesis_block )

	var geth = spawn( geth_path, ['--networkid', '1234234', '--genesis', geth_genesis_block, '--datadir', geth_datadir, '--rpc', '--shh'] )

	geth.on('close', function(code){
		alert('Geth Exited with code: ' + code);
		ethMenu.items[0].label = "Status: Not Running"
		ethMenu.items[1].label = "Start"
		kill( ethProcess )
		ethProcess = null;
	})
	geth.stdout.on('data', function (data) {
		console.log('geth stdout: ' + data);
	});

	geth.stderr.on('data', function (data) {
		console.log('geth stderr: ' + data);
		ethMenu.items[0].label = "Status: Running"
		ethMenu.items[1].label = "Stop"
		web3.connect( ethMenu )
	});

	ethProcess = geth;

}

function kill (process) {
	console.log("Killing process: ", process )
	if (process.stdin) process.stdin.pause();
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
		ipfsMenu.items[0].label = "Status: Not Running"
		ipfsMenu.items[1].label = "Start"
		kill( ipfsProcess )
		ipfsProcess = null;
	})
	daemon.stdout.on('data', function (data) {
		console.log('ipfs stdout: ' + data);
		ipfsMenu.items[0].label = "Status: Running"
		ipfsMenu.items[1].label = "Stop"
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
		label: 'About \u039Ethos',
		icon: './app/images/icon-tray.png',
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
		label: 'Status: Not Running',
		enabled: false
	})

	ipfsToggle = new gui.MenuItem({
		label: 'Start',
		click: function(){ toggleIPFS( ipfsMenu ) }
	})

	ethStatus = new gui.MenuItem({
		label: 'Status: Not Running',
		enabled: false
	})

	ethToggle = new gui.MenuItem({
		label: 'Start',
		click: function(){ toggleGeth( ethMenu ) }
	})


	ipfsMenu.append( ipfsStatus )
	ipfsMenu.append( ipfsToggle )
	
	ethMenu.append( ethStatus )
	ethMenu.append( ethToggle )

	menu.append( about )
	menu.append( ipfs )
	menu.append( eth )
	menu.append( debug )
	menu.append( quit )

	toggleGeth( ethMenu )
	toggleIPFS( ipfsMenu )

	console.log( "Ξthos initialized: ok" )
	
}