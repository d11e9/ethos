
path = require 'path'
web3 = require 'web3'

module.exports = (gui) ->
	process.on 'uncaughtException', (msg)->
		console.error "Error: Uncaught exexption: #{ msg }"

	os = process.platform
	ext = if os is 'win32' then '.exe' else ''

	win = gui.Window.get()

	Config = require './Config.coffee'
	EthosMenu = require './EthosMenu.coffee'
	EthProcess = require './EthProcess.coffee'
	IPFSProcess = require './IPFSProcess.coffee'

	console.log( "Ξthos initializing..." )
	config = new Config()
	config.load()

	win.window.onload = ->
		win.window.win = win
		win.window.eth = ethProcess = new EthProcess({os, ext, config})
		win.window.ipfs = ipfsProcess = new IPFSProcess({os, ext, config})
		win.window.ethos = menu = new EthosMenu({gui, ipfsProcess, ethProcess})

		ethProcess.start() if config.flags.ethStart
		ipfsProcess.start() if config.flags.ipfsStart

		global.ethos = config
		console.log( "Ξthos initialized: ok" )