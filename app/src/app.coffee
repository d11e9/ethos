alert = window.alert

module.exports = (gui) ->
	process.on 'uncaughtException', (msg)->
		alert "Error: Uncaught exexption: #{ msg }"

	os = process.platform
	ext = ''
	ext = '.exe' if os is 'win32'
		

	path = require 'path'
	web3 = require 'web3'
	spawn = require( 'child_process' ).spawn
	EthosMenu = require './EthosMenu.coffee'
	EthProcess = require './EthProcess.coffee'
	IPFSProcess = require './IPFSProcess.coffee'

	console.log( "Ξthos initializing..." )

	web3.connect = (ethMenu) ->
		tries = 0
		connect = ->
			try
				web3.setProvider( new web3.providers.HttpProvider('http://localhost:8545') )
				console.log( "Ethereum coinbase: ", web3.eth.coinbase )
				console.log( "Ethereum accounts: ", web3.eth.accounts )
			catch error
				console.log( "Error connecting to local Ethereum node" )
				console.log( error )
				tries++
				setTimeout( connect, 100 ) if tries < 10
		setTimeout( connect, 100 )



	window.onload = ->		
		ethProcess = new EthProcess({os, ext})
		ipfsProcess = new IPFSProcess({os, ext})
		menu = new EthosMenu({gui,ipfsProcess, ethProcess})

		ethProcess.start()
		ipfsProcess.start()

		ethProcess.on 'status', (running) ->
			web3.connect() if running

		console.log( "Ξthos initialized: ok" )