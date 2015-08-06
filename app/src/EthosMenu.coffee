web3 = require 'web3'


wrap = (func) ->
	oldOnError = window.onerror
	window.onerror = ->
	func.apply( this, arguments )
	window.onerror = oldOnError

module.exports = class EthosMenu
	constructor: ({gui, @ethProcess, @ipfsProcess})->
		EthereumMenu = require( './EthereumMenu.coffee')(gui)

		@menu = new gui.Menu()
		@ipfsMenu = new gui.Menu()

		@ethMenu = new EthereumMenu( process: @ethProcess )

		@tray = new gui.Tray
			title: ''
			icon: "./app/images/icon-tray.png"
			menu: @menu

		@tray.on 'click', () ->
			window.alert("Tray click")
		
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
			click: ->
				child = gui.Window.open 'app://ethos/app/about.html',
					"icon": "app/images/icon-tray.ico",
				    "title": "Ethos",
				    "toolbar": true,
				    "frame": true,
				    "show": false,
				    "show_in_taskbar": false,
				    "width": 800,
				    "height": 500,
				    "position": "center",
				    "min_width": 400,
				    "min_height": 200,
				    "max_width": 800,
				    "max_height": 600
				mb = new gui.Menu({type:"menubar"})
				mb.createMacBuiltin("About Ethos")
				child.menu = mb
				global.about = child

				#gui.Shell.openExternal('http://localhost:8080/ipfs/ethosAbout')

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
				@ipfsProcess.info (err,res) ->
					gui.Shell.openExternal("http://localhost:8080/ipns/#{ res.info.ID}") unless err

		@ipfsProcess.on 'status', (running) =>
			if running
				ipfsStatus.label = "Status: Connecting"
				ipfsToggle.label = "Stop"
				ipfsAddFile.enabled = false
				ipfsInfo.enabled = false
				try
					@ipfsProcess.api.id (err, info) ->
						ipfsStatus.label = "Status: Connected" unless err
						ipfsAddFile.enabled = !err
						ipfsInfo.enabled = !err
				catch err
			else
				ipfsStatus.label = "Status: Not Running"
				ipfsToggle.label = "Start"
				ipfsAddFile.enabled = false
				ipfsInfo.enabled = false
			
		@ipfsMenu.append( ipfsStatus )
		@ipfsMenu.append( ipfsToggle )
		@ipfsMenu.append( ipfsAddFile )
		@ipfsMenu.append( ipfsInfo )

		@menu.append( about )
		@menu.append( ipfs )
		@menu.append( @ethMenu.get() )
		@menu.append( debug )
		@menu.append( quit )

		@tray