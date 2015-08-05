web3 = require 'web3'


module.exports = class EthosMenu
	constructor: ({gui, @ethProcess, @ipfsProcess})->
		@menu = new gui.Menu()
		@ipfsMenu = new gui.Menu()
		@ethMenu = new gui.Menu()

		@tray = new gui.Tray
			title: ''
			icon: "./app/images/icon-tray.png"
			menu: @menu

		@tray.on 'click', () ->
			alert("TRay click")
		
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

		eth = new gui.MenuItem
			label: 'Ethereum'
			submenu: @ethMenu

		ipfsStatus = new gui.MenuItem
			label: 'Status: Not Running'
			enabled: false

		ipfsToggle = new gui.MenuItem
			label: 'Start'
			click: => @ipfsProcess.toggle()

		ipfsAddFile = new gui.MenuItem
			label: 'Add File'
			click: => @ipfsProcess.addFile()

		ipfsInfo = new gui.MenuItem
			label: 'Info'
			click: => @ipfsProcess.info()

		ethStatus = new gui.MenuItem
			label: 'Status: Not Running'
			enabled: false

		ethToggle = new gui.MenuItem
			label: 'Start'
			click: => @ethProcess.toggle()

		ethAccounts = new gui.MenuItem
			label: 'Accounts'
			submenu: new gui.Menu()

		ethNewAccount = 
			label: 'New Account'
			click: => @ethProcess.newAccount()

		updateStatus = (stat, toggle) ->
			(running) ->
				if running
					stat.label = "Status: Running"
					toggle.label = "Stop"
				else
					stat.label = "Status: Not Running"
					toggle.label = "Start"

		@ethProcess.on 'status', updateStatus( ethStatus, ethToggle )
		@ipfsProcess.on 'status', updateStatus( ipfsStatus, ipfsToggle )
		@ethProcess.on 'status', (running) ->
			ethAccounts.submenu = new gui.Menu()
			ethAccounts.submenu.append( new gui.MenuItem(ethNewAccount) )
			web3.eth.getAccounts (err, accounts) ->
				return if err
				ethAccounts.submenu.append( new gui.MenuItem( label: acc ) ) for acc in accounts
			
		@ipfsMenu.append( ipfsStatus )
		@ipfsMenu.append( ipfsToggle )
		@ipfsMenu.append( ipfsAddFile )
		@ipfsMenu.append( ipfsInfo )
		
		@ethMenu.append( ethStatus )
		@ethMenu.append( ethToggle )
		@ethMenu.append( ethAccounts )

		@menu.append( about )
		@menu.append( ipfs )
		@menu.append( eth )
		@menu.append( debug )
		@menu.append( quit )

		@tray