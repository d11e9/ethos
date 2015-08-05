path = require 'path'
fs = require 'fs'
cp = require 'child_process'
web3 = require 'web3'
spawn = cp.spawn
Backbone = require 'backbone'

module.exports = class EthProcess extends Backbone.Model
	constructor: ({@os, ext}) ->
		@process = null
		@connected = false
		@path = path.join( process.cwd(), "./bin/#{ @os }/geth/geth#{ ext }" )
		@datadir = path.join( process.cwd(), './eth' )
		@ipcPath = path.join( @datadir, './geth.ipc' )

		fs.chmodSync( @path, '755') if @os is 'darwin'
		@listenTo @, 'status', (running) =>
			return if running and @connected
			@connected = false if @connected and !running
			return unless running
			web3.setProvider( new web3.providers.IpcProvider( @ipcPath ) )
			console.log "ETH checking ipc connection", @connected, running
			web3.eth.getBlockNumber (err, blockNumber) =>
				if err
					console.log err
					@connected = false
				else
					@connected = true
					console.log( "ETH block ##{ blockNumber }" )
				@trigger( 'connected', @connected )


	start: ->
		console.log( @path, @datadir )
		@process = spawn( @path, [ '--datadir', @datadir, '--rpc', '--shh'] )

		@process.on 'close', (code) =>
			console.log('Geth Exited with code: ' + code)
			@kill()
		
		@process.stdout.on 'data', (data) =>
			console.log('geth stdout: ' + data)
			@trigger( 'status', !!@process )

		@process.stderr.on 'data', (data) =>
			console.log('geth stderr: ' + data)
			@trigger( 'status', !!@process )

	toggle: ->
		if @process
			@kill()
		else
			@start()

	newAccount: ->
		console.log( "TODO: Create new Accounts" )

	kill: ->
		@process?.stdin?.pause()
		spawn("taskkill", ["/pid", @process?.pid, '/f', '/t']) unless @os is 'darwin'
		@process?.kill?('SIGINT')
		@process = null
		@trigger( 'status', !!@process )