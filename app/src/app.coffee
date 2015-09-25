
fs = require 'fs'

module.exports = (gui, execPath) ->

	web3 = require execPath 'web3'
	chokidar = require execPath 'chokidar'
	browserify = require execPath 'browserify'
	coffeeify = require execPath 'coffeeify'
	lessify = require execPath 'lessify'

	global.execPath = execPath

	process.on 'uncaughtException', (msg)->
		window.console.log "Error: Uncaught Exception: ", msg

	os = process.platform
	ext = if os is 'win32' then '.exe' else ''

	win = gui.Window.get()
	
	if os is 'darwin'
		mb = new gui.Menu( type: 'menubar' )
		mb.createMacBuiltin( 'Ξthos', hideEdit: false )
		win.menu = mb

	Config = require './Config.coffee'
	EthosMenu = require './EthosMenu.coffee'
	EthProcess = require './EthProcess.coffee'
	IPFSProcess = require './IPFSProcess.coffee'

	# Build wallet files
	writeWallet = (err,src) ->
		console.error( err ) if err
		fs.writeFile( "./app/wallet/wallet.js", src )
		console.log "Writing new wallet file"

	watcher = chokidar.watch('./app/wallet/wallet.coffee')
	watcher.add( './app/wallet/wallet.less')
	buildBundle = ->
		b = browserify
			transform: [coffeeify, lessify]
			cache: {}
			packageCache: {}
			entries: ['./app/wallet/wallet.coffee']

		b.bundle( writeWallet )

	watcher.on 'change', buildBundle
	buildBundle()


	console.log( "Ξthos initializing..." )

	ethosPackge = require( '../../package.json' )
	config = new Config( ethosPackge )
	config.load()

	DialogManager = require('./EthosDialogManager.coffee')(gui, config)
	dialogManager = new DialogManager()

	EthRpcProxy = require './EthRpcProxy.coffee'
	EthRpcProxy(web3, config, dialogManager)

	DAppServer = require './DAppServer.coffee'
	DAppServer({config})

	win.window.onload = ->
		win.window.win = win
		win.window.log = -> window.console.log arguments
		win.window.eth = ethProcess = new EthProcess({os, ext, config, dialogManager})
		win.window.ipfs = ipfsProcess = new IPFSProcess({os, ext, config, gui, dialogManager})
		win.window.ethos = menu = new EthosMenu({gui, ipfsProcess, ethProcess, config, dialogManager })

		ethProcess.start() if config.getBool( 'ethStart' )
		ipfsProcess.start() if config.getBool( 'ipfsStart' )

		console.log( "Ξthos initialized: ok" )
		menu.showAbout() if config.getBool( 'showAbout' )