path = require 'path'
fs = require 'fs'
cp = require 'child_process'

spawn = cp.spawn
Backbone = require 'backbone'

module.exports = class EthProcess extends Backbone.Model
	constructor: ({@os, ext}) ->
		@process = null
		@connected = false
		@path = path.join( process.cwd(), "./bin/#{ @os }/geth/geth#{ ext }" )
		@datadir = path.join( process.cwd(), './eth' )
		@web3 = require 'web3'
		@ipcPath = if @os is 'darwin'
				path.join( @datadir, './geth.ipc' )
			else
				'\\\\.\\pipe\\geth.ipc'

		fs.chmodSync( @path, '755') if @os is 'darwin'
		@web3.setProvider( new @web3.providers.IpcProvider( @ipcPath ) )

		@listenTo @, 'status', (running) =>
			return if running and @connected
			@connected = false if @connected and !running
			return unless running
			
			console.log "ETH checking ipc connection", @connected, running
			@web3.eth.getBlockNumber (err, blockNumber) =>
				if err
					console.log err
					@connected = false
				else
					@connected = true
					console.log( "ETH block ##{ blockNumber }" )
				@trigger( 'connected', @connected )


	start: ->
		console.log( @path, @datadir )
		@process = spawn( @path, [ '--datadir', @datadir, '--rpc', '--shh', '--ipcapi', 'admin,db,eth,debug,miner,net,shh,txpool,personal,web3'] )

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

	newAccount: =>
		console.log( "TODO: Create new Accounts" )
		pass1 = window.prompt( "Enter passphrase: ")
		pass2 = window.prompt( "Repeat passphrase: ")
		if pass1 is pass2
			@web3.currentProvider.sendAsync({
				jsonrpc: "2.0",
				id: 1,
				method: "personal_newAccount",
				params: [pass1]
				}, (err,res) -> console.log( "Account created: ", res.result ))
		else
			alert("Passphrases do not match.")

		@web3.eth.getAccounts (err,accounts) ->
			console.log("Accounts:", accounts)

	kill: ->
		@process?.stdin?.pause()
		spawn("taskkill", ["/pid", @process?.pid, '/f', '/t']) unless @os is 'darwin'
		@process?.kill?('SIGINT')
		@process = null
		@trigger( 'status', !!@process )