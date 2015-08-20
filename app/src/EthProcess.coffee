path = require 'path'
fs = require 'fs'
cp = require 'child_process'
Backbone = require 'backbone'

spawn = cp.spawn
alert = window.alert
prompt = window.prompt
confirm = window.confirm

module.exports = class EthProcess extends Backbone.Model
	constructor: ({@os, ext, @config}) ->
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
		

		@listenTo @config, 'restartEth', =>
			console.log( "RESTART ETH")
			@kill() if @process
			@start()

		@listenTo( @, 'status', @checkStatus )


	checkStatus: (running) =>
		return if running and @connected
		@connected = false if !running
		
		console.log "ETH checking connection", @connected, running, @web3.currentProvider
		@web3.eth.getBlockNumber (err, blockNumber) =>
			console.log "Recieved data from web3.getBlockNumber", arguments
			if err
				console.log err
				@connected = false
			else
				@connected = true
				console.log( "ETH block ##{ blockNumber }" )
			@trigger( 'connected', @connected )
		@trigger( 'connected', @connected )


	start: ->
		if @config.getBool( 'ethRemoteNode' )
			@rpcPath = @config.get( 'ethRemoteNodeAddr' )
			console.log "Connecting to Remote Ethereum Node: #{ @rpcPath }"
			@web3.setProvider( new @web3.providers.HttpProvider( @rpcPath ) )
			rpcProviderJs = """
				web3.setProvider( new web3.providers.HttpProvider( "#{ @rpcPath }" ) );
			"""
			fs.writeFile path.join( process.cwd(), './app/js/web3rpc.js' ), rpcProviderJs, (err) ->
				console.log( err )
			@trigger( 'status', true )
			return

		console.log "Connecting to Local Ethereum Node: ipc:#{ @rpcPath }"
		@web3.setProvider( new @web3.providers.IpcProvider( @ipcPath ) )

		rpc = ['--rpc', '--rpcaddr', @config.flags.ethRpcAddr, '--rpcport', @config.flags.ethRpcPort, '--rpccorsdomain', @config.flags.ethRpcCorsDomain]
		args = [ '--datadir', @datadir,'--shh', '--ipcapi', 'admin,db,eth,debug,miner,net,shh,txpool,personal,web3']
		args = args.concat( rpc ) if @config.getBool( 'ethRpc' )

		console.log( "STARTING ETH: #{ @path } #{ args.join(' ') }")
		@process = spawn( @path, args )

		@process.on 'close', (code) =>
			console.log('Geth Exited with code: ' + code)
			@kill()
		
		@process.stdout.on 'data', (data) =>
			console.log('geth stdout: ' + data) if @config.getBool('logging')
			@trigger( 'status', !!@process )

		@process.stderr.on 'data', (data) =>
			console.log('geth stderr: ' + data) if @config.getBool('logging')
			@trigger( 'status', !!@process )

		

	toggle: ->
		if @connected
			@kill()
		else
			@start()

	unlock: (acc) =>
		passphrase = prompt("Enter passphrase to unlock account: #{ acc }")
		jsonrpc =
			jsonrpc: "2.0"
			id: 1
			method: "personal_unlockAccount"
			params: [acc, passphrase]
		@web3.currentProvider.sendAsync jsonrpc, (err,res) ->
			if res.error
				alert( res.error.message )
			console.log( "Account Unlocked: ", res?.result is true )

	newAccount: =>
		pass1 = prompt( "Enter passphrase: ")
		pass2 = prompt( "Repeat passphrase: ")
		if pass1 is pass2
			@web3.currentProvider.sendAsync({
				jsonrpc: "2.0",
				id: 1,
				method: "personal_newAccount",
				params: [pass1]
				}, (err,res) -> console.log( "Account created: ", res.result ))
		else
			alert("Error: Passphrases do not match. New account not created.")

		@web3.eth.getAccounts (err,accounts) ->
			console.log("Accounts:", accounts)

	toggleMining: =>
		@web3.eth.getMining (err, mining) =>
			if err
				console.log err
				return
			method = if mining then "miner_stop" else "miner_start"
			rpcjson =
				jsonrpc: "2.0"
				id: 1
				method: method
				params: []
			@web3.currentProvider.sendAsync( rpcjson, (err,res) -> console.log( "Mining toggled: ", res ))
	
	importWallet: (filePath, cb) ->
		password = prompt("Enter passphrase to import wallet") + "\n"
		process = spawn( @path, ["--datadir", @datadir, "wallet", "import", filePath])
		process.stdout.on 'data', (data) ->
			console.log "geth import stdout:", data.toString('utf8')
			process.stdin.write(password)

		process.stderr.on 'data', (data) ->
			alert "Import Error: #{ data.toString('utf8') }"

		process.on 'close', (code) ->
			console.log "geth import CLOSE: ", code
			cb( code != 0 )

	kill: ->
		console.log("KILLING ETHEREUM PROCESS")
		@process?.stdin?.pause()
		spawn("taskkill", ["/pid", @process?.pid, '/f', '/t']) unless @os is 'darwin'
		@process?.kill?('SIGINT')
		@process = null
		@web3.currentProvider = null;
		@web3.setProvider( null )
		@connected = false
		@trigger( 'status', false )