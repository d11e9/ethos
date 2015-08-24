
path = require 'path'
web3 = require 'web3'


module.exports = (gui) ->
	process.on 'uncaughtException', (msg)->
		window.alert "Error: Uncaught exexption: #{ msg }"

	os = process.platform
	ext = if os is 'win32' then '.exe' else ''

	win = gui.Window.get()

	Config = require './Config.coffee'
	EthosMenu = require './EthosMenu.coffee'
	EthProcess = require './EthProcess.coffee'
	IPFSProcess = require './IPFSProcess.coffee'

	console.log( "Ξthos initializing..." )

	ethosPackge = require( '../../package.json' )
	config = new Config( ethosPackge )
	config.load()

	win.window.onload = ->
		win.window.win = win
		win.window.log = -> window.console.log arguments
		win.window.eth = ethProcess = new EthProcess({os, ext, config})
		win.window.ipfs = ipfsProcess = new IPFSProcess({os, ext, config})
		win.window.ethos = menu = new EthosMenu({gui, ipfsProcess, ethProcess, config})

		ethProcess.start() if config.getBool( 'ethStart' )
		ipfsProcess.start() if config.getBool( 'ipfsStart' )

		global.ethos = config
		console.log( "Ξthos initialized: ok" )
		menu.showAbout() if config.getBool( 'showAbout' )