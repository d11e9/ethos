path = require 'path'
fs = require 'fs'
cp = require 'child_process'
spawn = cp.spawn
exec = cp.exec
Backbone = require 'backbone'
ipfsApi = require 'ipfs-api'


module.exports = class IPFSProcess extends Backbone.Model
	constructor: ({@os, ext, @config, @gui}) ->
		@process = null
		@path = path.join( process.cwd(), "./bin/#{ @os }/ipfs/ipfs#{ ext }")
		@api = new ipfsApi('localhost', 5001)
		fs.chmodSync( @path, '755') if @os is 'darwin'
		@connected = false
		@on 'status', (running) =>
			if running and !@conneted
				exec "#{@path} config show", (err, stdout, stderr) =>
					if !err
						@ipfsConfig = JSON.parse( stdout )
						console.log( 'IPFS Config:', @ipfsConfig )
						@connected = true
						@trigger( 'connected')
					else
						@connected = false
						console.log "IPFS Error:", err

				# @api.config.show (err, ipfsConfig) =>
				# 	@api.swarm.peers (err, peers) =>
				# 		if err
				# 			@connected = false
				# 		else
				# 			@connected = true
				# 			@ipfsConfig = ipfsConfig
				# 			@trigger( 'connected' )
				# 			console.log( "IPFS config: ", err, ipfsConfig)

	start: ->
		datastore = path.join( process.cwd(), './ipfs' )
		args = ['daemon', '--config', datastore]

		exec "#{@path} init -f --config #{datastore}", (err, stdout, stderr) =>

			console.log "IFPS Starting new daemon. args: #{ @path } #{ args.join(' ') }"
			@process =  spawn( @path, args )
			@stderr = ''
			@stdout = ''

			@process.on 'close', (code) =>
				console.log('IFPS Exited with code: ' + code)
				@kill()
			
			@process.stdout.on 'data', (data) =>
				console.log('IFPS stdout: ' + data) if @config.getBool('logging')
				@stdout += data
				@trigger( 'status', !!@process )

			@process.stderr.on 'data', (data) =>
				console.log('IFPS stderr: ' + data) if @config.getBool('logging')
				@stderr += data
				@trigger( 'status', !!@process )

	toggle: ->
		if @process
			@kill()
		else
			@start()

	info: (cb) =>
		@api.id (err,info) =>
			console.log( "IPFS ID: #{ info.ID }" )
			if err
			 	cb( err, null )
			 	return
			@api.pin.list (err,pins) ->
				console.log( "IFPS pinned files:", pins)
				if err
			 		cb( err, null )
			 		return
				cb( err, info: info, pins: pins )
				
	getGateway: ->
		@ipfsConfig.Addresses.Gateway.replace('/ip4/','').replace('/tcp/', ':')

	getAPI: ->
		@ipfsConfig.Addresses.API.replace('/ip4/','').replace('/tcp/', ':')

	addFile: (callback) ->
		chooser = window.document.querySelector('#addFile')
		chooser.addEventListener "change", (evt) =>
			filePath = evt.target.value
			return if filePath is ''
			evt.target.value = ""
			@gui.Window.get().hide()
			exec "#{@path} add -q #{filePath}", (err, stdout, stderr) ->
				callback( err, stdout )
		chooser.click()

	addFolder: (callback) ->
		chooser = window.document.querySelector('#addFolder')
		chooser.addEventListener "change", (evt) =>
			filePath = evt.target.value
			return if filePath is ''
			evt.target.value = ""
			@gui.Window.get().hide()
			exec "#{@path} add -r -q #{filePath}", (err, stdout, stderr) ->
				callback( err, stdout.split("\n").reverse()[1] )
		chooser.click()

	kill: ->
		@process?.stdin?.pause()
		spawn("taskkill", ["/pid", @process?.pid, '/f', '/t']) unless @os is 'darwin'
		@process?.kill?('SIGINT')
		@process = null
		@trigger( 'status', !!@process )