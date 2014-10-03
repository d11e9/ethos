console.log( 'Bootstraping Ethos...' )

if global?
	try
		gui = require('nw.gui')
	catch err
		console.log( "Error: ", err )

	app = gui.App

	windows = []

	# Attach event bus / vent to global object using EventEmitter
	EventEmitter = require( 'events' )
	global.vent = new EventEmitter()

	# Get the bootstrap window (this one) and hide it.
	win = gui.Window.get()
	win.ethos = window.ethos = true
	win.hide()

	windows.push( win )

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
	
	mainWindow = gui.Window.open( 'http://eth:8080/', mainWindowOptions )
	mainwin = gui.Window.get( mainWindow )
	windows.push( mainwin )
	mb = new gui.Menu( type:"menubar" )

	if process.platform is 'darwin'
		mb.createMacBuiltin( "Ethos" )
		mainwin.menu = mb

	mainwin.onerror = -> alert('err')

	global.showDialog = (data = {}) ->
		# Create a new dialog window for notifications
		dialogWindowOptions =
			frame: false
			toolbar: false
			resizable: false
			width: data.width or 400
			height: data.height or 200

		dialogWindow = gui.Window.open( data.url or 'http://eth:8080/ethos/dialog', dialogWindowOptions )
		dialogwin = gui.Window.get( dialogWindow )

	global.showGlobalDev = ->
		console.log "showGlobalDev requested"
		win.showDevTools()

	global.vent.on 'close:dialog', (data) ->
		console.log "'close:dialog' event fired. data:", data

	

console.log( 'Ethos Bootstrap end: ok.' )