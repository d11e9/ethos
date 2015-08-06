alert = window.alert

module.exports = (gui) ->
	process.on 'uncaughtException', (msg)->
		alert "Error: Uncaught exexption: #{ msg }"

	os = process.platform
	ext = ''
	ext = '.exe' if os is 'win32'

	mb = new gui.Menu(type:"menubar")
	mb.createMacBuiltin("Ethos") if os is 'darwin'
	gui.Window.get().menu = mb
		

	path = require 'path'
	web3 = require 'web3'
	spawn = require( 'child_process' ).spawn
	EthosMenu = require './EthosMenu.coffee'
	EthProcess = require './EthProcess.coffee'
	IPFSProcess = require './IPFSProcess.coffee'

	console.log( "Ξthos initializing..." )

	window.onload = ->		
		ethProcess = new EthProcess({os, ext})
		ipfsProcess = new IPFSProcess({os, ext})
		menu = new EthosMenu({gui,ipfsProcess, ethProcess})

		ethProcess.start()
		ipfsProcess.start()

		console.log( "Ξthos initialized: ok" )