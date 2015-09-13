
path = require 'path'
web3 = require 'web3'

module.exports = (gui) ->
	process.on 'uncaughtException', (msg)->
		window.console.log "Error: Uncaught exexption: #{ msg }"

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

	console.log( "Ξthos initializing..." )

	ethosPackge = require( '../../package.json' )
	config = new Config( ethosPackge )
	config.load()

	EthRpcProxy = require './EthRpcProxy.coffee'
	EthRpcProxy(web3, config)

	win.window.onload = ->
		win.window.win = win
		win.window.log = -> window.console.log arguments
		win.window.eth = ethProcess = new EthProcess({os, ext, config})
		win.window.ipfs = ipfsProcess = new IPFSProcess({os, ext, config, gui})
		win.window.ethos = menu = new EthosMenu({gui, ipfsProcess, ethProcess, config})

		ethProcess.start() if config.getBool( 'ethStart' )
		ipfsProcess.start() if config.getBool( 'ipfsStart' )

		global.ethos = config
		console.log( "Ξthos initialized: ok" )
		menu.showAbout() if config.getBool( 'showAbout' )