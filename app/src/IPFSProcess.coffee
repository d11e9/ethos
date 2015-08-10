path = require 'path'
fs = require 'fs'
cp = require 'child_process'
spawn = cp.spawn
Backbone = require 'backbone'
ipfsApi = require 'ipfs-api'



module.exports = class IPFSProcess extends Backbone.Model
	constructor: ({@os, ext, @config}) ->
		@process = null
		@path = path.join( process.cwd(), "./bin/#{ @os }/ipfs/ipfs#{ ext }")
		@api = new ipfsApi()
		fs.chmodSync( @path, '755') if @os is 'darwin'
		@on 'status', (running) =>
			if running
				@api.config.show (err, config) =>
					@config = config
					@trigger( 'connected' ) unless err
					console.log( "IPFS config: ", err, config)

	start: ->
		console.log( @path )

		@process =  spawn( @path, ['daemon', '--init'] )

		@process.on 'close', (code) =>
			console.log('IFPS Exited with code: ' + code)
			@kill()
		
		@process.stdout.on 'data', (data) =>
			console.log('IFPS stdout: ' + data) if @config.get('logging')
			@trigger( 'status', !!@process )

		@process.stderr.on 'data', (data) =>
			console.log('IFPS stderr: ' + data) if @config.get('logging')
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

	addFile: ->
		chooser = window.document.querySelector('#ipfsAddFile')
		console.log "TODO: IPFS Add file", chooser
		chooser.addEventListener "change", (evt) =>
			filePath = evt.target.value
			console.log "TODO: IPFS add file", filePath
			@api.add filePath, (err,res) =>
				if err or !res
					console.log "Error:", err
				else
					for file in res
						console.log "Added: ", file.Hash 
						@api.pin.add( file.Hash )
		chooser.click()

	kill: ->
		@process?.stdin?.pause()
		spawn("taskkill", ["/pid", @process?.pid, '/f', '/t']) unless @os is 'darwin'
		@process?.kill?('SIGINT')
		@process = null
		@trigger( 'status', !!@process )