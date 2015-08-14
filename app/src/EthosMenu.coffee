web3 = require 'web3'


newWindowOptions =
	icon: "app/images/icon-tray.ico"
	title: "Ethos"
	toolbar: false
	frame: true
	show: true
	show_in_taskbar: true
	width: 800
	height: 500
	position: "center"
	min_width: 400
	min_height: 200

module.exports = class EthosMenu
	openWindow: (url) ->
		global.child = @gui.Window.open( url, newWindowOptions )
		setTimeout ( -> child.focus() ), 100

	constructor: ({@gui, @ethProcess, @ipfsProcess})->
		gui = @gui
		EthereumMenu = require( './EthereumMenu.coffee')(gui)
		@menu = new gui.Menu()
		@ipfsMenu = new gui.Menu()
		@ethMenu = new EthereumMenu( process: @ethProcess )

		@tray = new gui.Tray
			title: ''
			icon: "./app/images/icon-tray.png"
			menu: @menu
		
		quit = new gui.MenuItem
			label: 'Quit'
			key: 'q'
			modifiers: 'ctrl-alt'
			click: =>
				@tray.remove()
				@ethProcess.kill()
				@ipfsProcess.kill()
				process.exit(0)

		about = new gui.MenuItem
			label: 'About \u039Ethos'
			click: => @openWindow( 'app://ethos/app/about.html' )

		settings = new gui.MenuItem
			label: 'Settings'
			click: => @openWindow( 'app://ethos/app/settings.html' )

		debug = new gui.MenuItem
			label: 'Debug'
			click: ->
				gui.Window.get().showDevTools()

		ipfs = new gui.MenuItem
			label: 'IPFS'
			submenu: @ipfsMenu

		ipfsStatus = new gui.MenuItem
			label: 'Status: Not Running'
			enabled: false

		ipfsToggle = new gui.MenuItem
			label: 'Start'
			click: => @ipfsProcess.toggle()

		ipfsAddFile = new gui.MenuItem
			label: 'Add File'
			enabled: false
			click: => @ipfsProcess.addFile()

		ipfsInfo = new gui.MenuItem
			label: 'Info'
			enabled: false
			click: =>
				@ipfsProcess.info (err,res) =>
					address = @ipfsProcess.config.Addresses.Gateway.replace('/ip4/','').replace('/tcp/', ':')
					console.log( "IPFS Gateway address: #{address}" )
					gui.Shell.openExternal("http://#{ address }/ipns/#{ res.info.ID}") unless err

		@ipfsProcess.on 'status', (running) =>
			ipfsStatus.label = "Status: Connecting"
			ipfsToggle.label = "Stop"
			ipfsAddFile.enabled = false
			ipfsInfo.enabled = false
			if !running
				ipfsStatus.label = "Status: Not Running"
				ipfsToggle.label = "Start"

		@ipfsProcess.on 'connected', =>
			@ipfsProcess.api.id (err, info) ->
				console.log( "IPFS connected: ", err, info)
				ipfsStatus.label = "Status: Connected" unless err
				ipfsAddFile.enabled = !err
				ipfsInfo.enabled = !err
			
		@ipfsMenu.append( ipfsStatus )
		@ipfsMenu.append( ipfsToggle )
		@ipfsMenu.append( ipfsAddFile )
		@ipfsMenu.append( ipfsInfo )

		@menu.append( about )
		@menu.append( settings )
		@menu.append( ipfs )
		@menu.append( @ethMenu.get() )
		@menu.append( debug )
		@menu.append( quit )

		@tray