web3 = require 'web3'



module.exports = class EthosMenu
	openWindow: (url) ->
		newWindowOptions =
			icon: "app/images/icon-tray.ico"
			title: "Ethos"
			toolbar: @config.getBool( 'debug' )
			frame: true
			show: true
			show_in_taskbar: true
			width: 800
			height: 500
			position: "center"
			min_width: 400
			min_height: 200
		global.child = @gui.Window.open( url, newWindowOptions )
		setTimeout ( -> child.focus() ), 100

	constructor: ({@gui, @ethProcess, @ipfsProcess, @config})->
		gui = @gui
		EthereumMenu = require( './EthereumMenu.coffee')(gui)
		DAppsMenu = require( './DAppsMenu.coffee')(gui)
		IPFSMenu = require('./IPFSMenu.coffee')(gui)

		@menu = new gui.Menu()
		@ipfsMenu = new IPFSMenu( process: @ipfsProcess, config: @config )
		@ethMenu = new EthereumMenu( process: @ethProcess, config: @config )
		@dappsMenu = new DAppsMenu( eth: @ethProcess, ipfs: @ipfsProcess, config: @config )

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


		@menu.append( about )
		@menu.append( settings )
		@menu.append( @ipfsMenu.get() )
		@menu.append( @ethMenu.get() )
		@menu.append( @dappsMenu.get() )
		@menu.append( debug )
		@menu.append( quit )

		@tray