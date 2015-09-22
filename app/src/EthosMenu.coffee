web3 = require 'web3'

root = this

module.exports = class EthosMenu
	openWindow: (name, width, height) ->
		self = this
		if !@[name]
			title = name
			title[0] = title[0].toUpperCase()
			newWindowOptions =
				icon: "app/images/icon-tray.ico"
				title: "\u039Ethos #{title}"
				toolbar: @config.getBool( 'debug' )
				frame: true
				show: true
				focus: true
				show_in_taskbar: true
				width: width or 800
				height: height or 500
				position: "center"
				min_width: 400
				min_height: 200
			
			win = @gui.Window.open( "app://ethos/app/#{name}.html", newWindowOptions )
			
			win.on 'loaded', ->
				win.window.config = self.config
				win.window.init()
			win.on 'close', ->
				this.close( true )
				self[name] = null
			@[name] = win
			setTimeout( ( => self[name].focus() ), 500 )
		else
			@[name].focus()


	showAbout: ->
		@openWindow( 'about', 986, 385 )

	constructor: ({@gui, @ethProcess, @ipfsProcess, @config})->
		gui = @gui
		@win = window
		EthereumMenu = require( './EthereumMenu.coffee')(gui)
		DAppsMenu = require( './DAppsMenu.coffee')(gui)
		IPFSMenu = require('./IPFSMenu.coffee')(gui)

		@menu = new gui.Menu()
		@ipfsMenu = new IPFSMenu( process: @ipfsProcess, config: @config )
		@ethMenu = new EthereumMenu( process: @ethProcess, config: @config )
		@dappsMenu = new DAppsMenu( eth: @ethProcess, ipfs: @ipfsProcess, config: @config )

		@ipfs = @ipfsMenu.get()
		@eth = @ethMenu.get()
		@dapps = @dappsMenu.get()
		@dappItems = []

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
				@dappsMenu.closeAll()
				process.exit(0)

		about = new gui.MenuItem
			label: 'About \u039Ethos'
			click: =>  @showAbout()

		getSeparator = ->
			new gui.MenuItem type :'separator'

		dappsRunning = new gui.MenuItem
			label: 'Running \u00D0Apps'
			enabled: false

		settings = new gui.MenuItem
			label: 'Settings'
			click: => @openWindow( 'settings' )				

		debug = new gui.MenuItem
			label: 'Debug'
			click: ->
				gui.Window.get().showDevTools()
				setTimeout( (=> gui.Window.get().showDevTools()), 300 )		

		@menu.append( about )
		@menu.append( settings )
		@menu.append( getSeparator() )
		@menu.append( @ipfs )
		@menu.append( @eth )
		@menu.append( getSeparator() )
		@menu.append( @dapps )
		@menu.append( getSeparator() )
		@menu.append( debug )
		@menu.append( quit )

		@tray