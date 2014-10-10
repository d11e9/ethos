try
	#global.winston.info( 'Ethos Node-Webkit: Bootstraping Ξthos...', process, global )

	_ = require 'underscore'
	querystring = require 'querystring'

	process.on "uncaughtException", (err) -> 
		#global.winston.error( "Ethos Node-Webkit: Uncaught Exception.", err)
		alert("error: " + err)

	if global?
		try
			gui = require('nw.gui')
		catch err
			console.log( "Error: ", err )

		app = gui.App

		# Attach event bus / vent to global object using EventEmitter
		EventEmitter = require( 'events' )	
		global.vent = new EventEmitter()

		global.windows =
			bootstrap: null
			main: null
			dialog: null
			dialogHidden: true

		# Get the bootstrap window (this one) and hide it.
		win = global.windows.bootstrap = gui.Window.get()	
		win.showDevTools()
		win.hide()


		# Create a new main window for app content.
		mainWindowOptions =
			show: true
			toolbar: true
			frame: true
			icon: "./app/images/ethos-logo.png"
			"inject-js-start": "./app/scripts/inject.bundle.js"
			position: "center"
			width: 1024
			height: 768
			min_width: 300
			min_height: 200
		
		mainWindow = global.windows.main = gui.Window.open( 'http://eth:8080/', mainWindowOptions )
		mainwin = gui.Window.get( mainWindow )
		
		mb = new gui.Menu( type:"menubar" )
		#mb.append(new gui.MenuItem({ label: 'Item A' }))

		mb.createMacBuiltin?( "Ethos" )
		mainwin.menu = mb

		mainwin.onerror = -> alert('err')
		mainWindow.on 'close', ->
			win.close()

		mainWindow.on 'focus', ->
			global.winston.info "Ethos MainWindow focus event. active Dialog: ", !global.windows.dialogHidden
			if global.windows.dialog?
				global.windows.dialog.focus() unless global.windows.dialogHidden

		global.showDialog = (data = {}) ->
			# Create a new dialog window for notifications
			defaultDialogWindowOptions =
				url: 'app://ethos/app/dialog.html'
				frame: false
				toolbar: false
				resizable: false
				width: 400
				height: 200
				query: {}
			dialogWindowOptions = _.defaults( data, defaultDialogWindowOptions )
			url = "#{ dialogWindowOptions.url }?#{ querystring.stringify( dialogWindowOptions.query ) }"
			global.winston.info "Ethos Node-Webkit: Show Dialog window. #{url}"
			dialogWindow = global.windows.dialog = gui.Window.open( url, dialogWindowOptions )

			global.windows.dialogHidden = false

			dialogWindow.on 'close', ->
				global.winston.info "Closing dialog window." 
				global.windows.dialogHidden = true
				global.windows.dialog?.hide()

			dialogWindow.on 'blur', ->
				global.winston.info "Dialog window blur."
				global.windows.dialog.focus() unless global.windows.dialogHidden

		global.showSettings = ->
			@showDialog
				query:
					page: 'settings'
				height: 600
				width: 600
				resizable: true

		global.showGlobalDev = ->
			global.winston.info "Ethos Node-Webkit: showGlobalDev requested."
			win.showDevTools()

	global?.winston.info( 'Ethos Node-Webkit: Ξthos Bootstrap end: ok.' )

catch bootstrapError
	alert( 'Bootstrap Error' )