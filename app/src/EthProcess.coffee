path = require 'path'
fs = require 'fs'
cp = require 'child_process'
net = require 'net'

Backbone = require global.execPath 'backbone'

spawn = cp.spawn
exec = cp.exec
alert = window.alert
prompt = window.prompt
confirm = window.confirm

$HOME = process.env.HOME || process.env.USERPROFILE;



module.exports = class EthProcess extends Backbone.Model
	root = this
	constructor: ({@os, ext, @config, @dialogManager}) ->
		@process = null
		@connected = false
		@path = path.join( process.cwd(), "./bin/#{ @os }/geth/geth#{ ext }" )
		@web3 = require global.execPath 'web3'

		fs.chmodSync( @path, '755') if @os is 'darwin'
		@listenTo @config, 'restartEth', =>
			console.log( "RESTART ETH")
			@kill() if @process
			@start()

		@listenTo( @, 'status', @checkStatus )

		global.ethLogRaw = ''
		global.ethLog = new Backbone.Model()


	checkStatus: (running) =>
		return if running and @connected
		@connected = false if !running
		@web3.eth.getBlockNumber (err, blockNumber) =>
			if err
				# console.error JSON.parse( err ).error.message
				@connected = false
			else
				@connected = true
				console.log "Ethereum connected."
				notification = new window.Notification "Ethos",
					body: "Ethereum Network Connected."
				notification.onshow = -> setTimeout( ( -> notification.close() ), 3000)
			@trigger( 'connected', @connected )
		
	console: =>
		console.log "Launching Ethereum console" 
		if @os is 'darwin'
			exec( "bash #{ path.join( @path, '../console.sh' ) } \"#{ @path } attach\"")
		else
			exec( "start cmd.exe /K \"#{@path} attach\"" )

	start: ->
		if @config.getBool( 'ethRemoteNode' )
			@rpcPath = "#{ @config.get( 'ethRemoteNodeAddr' ) }:#{ @config.get( 'ethRemoteNodePort' ) }"
			console.log "Connecting to Remote Ethereum Node: #{ @rpcPath }"
			@web3.setProvider( new @web3.providers.HttpProvider( @rpcPath ) )
			rpcProviderJs = "web3.setProvider( new web3.providers.HttpProvider( '#{ @rpcPath }' ) );"
			fs.writeFile path.join( process.cwd(), './app/js/web3rpc.js' ), rpcProviderJs, (err) -> console.log( err ) if err
			@trigger( 'status', true )
			return


		@datadir = if @config.get('ethPrivateTestNet')
			path.join( process.cwd(), './eth' )
		else
			if @os is 'darwin'
				path.join( $HOME, "Library/Ethereum" )
			else
				path.join( $HOME, ".ethereum" )

		@ipcPath = if @os is 'darwin'
				path.join( @datadir, "geth.ipc" )
			else
				'\\\\.\\pipe\\geth.ipc'

		rpcProviderJs = "web3.setProvider( new web3.providers.HttpProvider( 'http://#{ @config.get('ethRpcAddr') }:#{ @config.get('ethRpcPort') }' ) );"
		fs.writeFile path.join( process.cwd(), './app/js/web3rpc.js' ), rpcProviderJs, (err) -> console.log( err ) if err

		rpc = ['--rpc', '--rpcapi', 'db,eth,net,shh,web3', '--rpcaddr', @config.get('ethRpcAddr'), '--rpcport', @config.get('ethRpcPort'), '--rpccorsdomain', @config.flags.ethRpcCorsDomain]
		args = [ '--datadir', @datadir, '--shh', '--ipcapi', 'admin,db,eth,debug,miner,net,shh,txpool,personal,web3', '--ipcpath', @ipcPath]
		priv = ['--maxpeers', 0, '--networkid', 1337, '--genesis', path.join(@datadir, 'test_genesis.json'), '--nodiscover', '--nat', 'none' ]
		
		args = args.concat( rpc ) if @config.get( 'ethRpc' )
		args = args.concat( priv ) if @config.get( 'ethPrivateTestNet' )

		console.log( "Running Ethereum node: #{ @path } #{ args.join(' ') }")
		@process = spawn( @path, args )
		@stderr = ''
		@stdout = ''

		@process.on 'close', (code) =>
			console.log('Geth Exited with code: ' + code)
			@kill()
		
		@process.stdout.on 'data', (data) =>
			@stdout += data
			for l in data.toString().split('\n') 
				line = "<div class='line'>#{l}</div>"
				global.ethLogRaw += line 
				global.ethLog.trigger( 'data', line )
			@trigger( 'status', !!@process )

		@process.stderr.on 'data', (data) =>
			@stderr += data
			for l in data.toString().split('\n')
				line = "<div class='line'>#{l}</div>"
				global.ethLogRaw += line 
				global.ethLog.trigger( 'data', line )
			@trigger( 'status', !!@process )

		logStream = fs.createWriteStream( path.join( @datadir, 'geth.log'), { flags: 'a' } )
		@process.stderr.pipe( logStream )
		@process.stdout.pipe( logStream )

		console.log "Connecting to local Ethereum node: ipc:#{ @ipcPath }"
		@web3.setProvider( new @web3.providers.IpcProvider( @ipcPath, net ) )


	toggle: ->
		if @connected
			@kill()
		else
			@start()

	unlock: (acc) =>
		self = this
		@dialogManager.newDialog
			title: 'Ethos: Account Unlock'
			body: "Enter passphrase to unlock account: <em>#{ acc }</em>"
			form: """
				<label>Passphrase: <input type="password" name="password"/></label>
				<div class="center">
					<input type="submit" name="unlock" value="Cancel"/>
					<input type="submit" name="unlock" value="Unlock"/>
				</div>
			"""
			callback: (result) ->
				return if result.unlock is 'Cancel'
				jsonrpc =
					jsonrpc: "2.0"
					id: 1
					method: "personal_unlockAccount"
					params: [acc, result.password]
				self.web3.currentProvider.sendAsync jsonrpc, (err,res) ->
					if res.error
						alert( res.error.message )
					console.log( "Account Unlocked: ", res?.result is true )

	newAccount: =>
		self = this
		@dialogManager.newDialog
			title: 'Ethos: New Account'
			body: "Choose a secure passphrase and dont forget it."
			form: """
				<input type="password" placeholder="Passphrase" name="password1"> <input type="password" placeholder="Re-type Passphrase"name="password2">
				<div class="center">
					<input type="submit" name="continue" value="Cancel">
					<input type="submit" name="continue" value="Create">
				</div>
			"""
			callback: (result) =>
				return if result.continue is 'Cancel'
				if result.password1 is result.password2
					self.web3.currentProvider.sendAsync({
						jsonrpc: "2.0",
						id: 1,
						method: "personal_newAccount",
						params: [result.password1]
					}, (err,res) ->
						window.console.log( "Account created: ", res.result )
						self.trigger( 'status', !!self.process )
					)
				else
					self.dialogManager.newDialog
						title: 'Ethos: New Account'
						body: "Passphrases do not match. New account not created."
						type: 'error'

	toggleMining: =>
		@web3.eth.getMining (err, mining) =>
			console.log( "Ethereum mining: ", !mining)
			if err
				console.log err
				return
			method = if mining then "miner_stop" else "miner_start"
			rpcjson =
				jsonrpc: "2.0"
				id: 1
				method: method
				params: []
			@web3.currentProvider.sendAsync( rpcjson, (err,res) -> console.error( err) if err )
	
	importWallet: (filePath, cb) ->
		self = this
		@dialogManager.newDialog
			title: 'Ethos: Wallet Import'
			body: "Locate your <em>.json</em> wallet file to import."
			form: """
				<input type="password" placeholder="Passphrase" name="password"> <input type="file" name="file">
				<div class="center">
					<input type="submit" name="import" value="Cancel">
					<input type="submit" name="import" value="Import">
				</div>
			"""
			callback: (result) ->
				return if result.import is 'Cancel'
				return unless result.file
				password = result.password + "\n"
				process = spawn( self.path, [ "wallet", "import", result.file])
				process.stdout.on 'data', (data) ->
					global.window.console.log "geth import stdout:", data.toString('utf8')
					process.stdin.write("y\n")
					process.stdin.write(password)

				process.stderr.on 'data', (data) ->
					self.dialogManager.newDialog
						title: 'Ethos: Import Error'
						body: data.toString('utf8')
						type: 'error'

				process.on 'close', (code) ->
					global.window.console.log "geth import CLOSE: ", code
					if code == 0
						self.dialogManager.newDialog
							title: 'Ethos: Wallet Import'
							body: "Wallet successfully imported."


	kill: ->
		console.log("Stopping Ethereum node.")
		@process?.stdin?.pause()
		spawn("taskkill", ["/pid", @process?.pid, '/f', '/t']) unless @os is 'darwin'
		@process?.kill?('SIGINT')
		@process = null
		@web3.currentProvider = null;
		@web3.setProvider( null )
		@connected = false
		@trigger( 'status', false )