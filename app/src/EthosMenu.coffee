
module.exports = class EthosMenu
	constructor: ({gui, @ethProcess, @ipfsProcess})->
		@menu = new gui.Menu()
		@ipfsMenu = new gui.Menu()
		@ethMenu = new gui.Menu()

		@tray = new gui.Tray({
			title: ''
			icon: "./app/images/icon-tray.png"
			menu: @menu
		})
		
		quit = new gui.MenuItem({
			label: 'Quit'
			key: 'q'
			modifiers: 'ctrl-alt'
			click: =>
				@tray.remove()
				process.exit(0)
		})

		about = new gui.MenuItem({
			label: 'About \u039Ethos'
			icon: './app/images/icon-tray.png'
			click: ->
				gui.Shell.openExternal('http://localhost:8080/ipfs/ethosAbout')
		})

		debug = new gui.MenuItem({
			label: 'Debug'
			click: ->
				gui.Window.get().showDevTools()
		})

		ipfs = new gui.MenuItem({
			label: 'IPFS'
			submenu: @ipfsMenu
		})

		eth = new gui.MenuItem({
			label: 'Ethereum'
			submenu: @ethMenu
		})

		ipfsStatus = new gui.MenuItem({
			label: 'Status: Not Running'
			enabled: false
		})

		ipfsToggle = new gui.MenuItem({
			label: 'Start'
			click: => @ipfsProcess.toggle()
		})

		ethStatus = new gui.MenuItem({
			label: 'Status: Not Running'
			enabled: false
		})

		ethToggle = new gui.MenuItem({
			label: 'Start'
			click: => @ethProcess.toggle()
		})

		updateStatus = (status, toggle) ->
			(running) ->
				if running
					status.label = "Status: Running"
					toggle.label = "Stop"
				else
					status.label = "Status: Not Running"
					toggle.label = "Start"

		@ethProcess.on 'status', updateStatus( ethStatus, ethToggle )
		@ipfsProcess.on 'status', updateStatus( ipfsStatus, ipfsToggle )
			
		@ipfsMenu.append( ipfsStatus )
		@ipfsMenu.append( ipfsToggle )
		
		@ethMenu.append( ethStatus )
		@ethMenu.append( ethToggle )

		@menu.append( about )
		@menu.append( ipfs )
		@menu.append( eth )
		@menu.append( debug )
		@menu.append( quit )

		@tray