path = require 'path'
fs = require 'fs'
cp = require 'child_process'
spawn = cp.spawn
exec = cp.exec
Backbone = require global.execPath 'backbone'
ipfsApi = require global.execPath 'ipfs-api'


module.exports = class IPFSProcess extends Backbone.Model
	constructor: ({@os, ext, @config, @gui, @dialogManager}) ->
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
						@connected = true
						console.log "IPFS connected."
						@trigger( 'connected')
					else
						@connected = false
						# console.log "IPFS Error:", err
			else
				@connected = false

		global.ipfsLogRaw = ''
		global.ipfsLog = new Backbone.Model()

	start: ->
		
		args = ['daemon', '--init']

		console.log "Running IFPS node: #{ @path } #{ args.join(' ') }"
		@process =  spawn( @path, args )
		@stderr = ''
		@stdout = ''

		@process.on 'close', (code) =>
			msg = "IPFS process exited with code: #{code}"
			if code == 1 then console.error( msg ) else console.log ( msg)
			@kill()
		
		@process.stdout.on 'data', (data) =>
			for l in data.toString().split('\n')
				line = "<div class='line'>#{l}</div>"
				global.ipfsLogRaw += line
				global.ipfsLog.trigger( 'data', line )
			@stdout += data
			@trigger( 'status', !!@process )

		@process.stderr.on 'data', (data) =>
			for l in data.toString().split('\n')
				line = "<div class='line'>#{l}</div>"
				global.ipfsLogRaw += line
				global.ipfsLog.trigger( 'data', line )
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
		self = this
		@dialogManager.newDialog
			title: 'Ethos: Add File'
			body: "Select the file you would like to add to IPFS."
			form: """
				<label><input type="file" name="file"></label>
				<div class="center">
					<input type="submit" name="add" value="Cancel">
					<input type="submit" name="add" value="Add">
				</div>
			"""
			callback: (result) ->
				return if result.add is 'Cancel'
				return unless result.file
				exec "#{self.path} add -q #{result.file}", (err, stdout, stderr) ->
					callback( err, stdout )

	addFolder: (callback) ->
		self = this
		@dialogManager.newDialog
			title: 'Ethos: Add Folder'
			body: "Select the folder you would like to add to IPFS."
			form: """
				<label><input type="file" multiple webkitdirectory="" directory="" name="file"></label>
				<div class="center">
					<input type="submit" name="add" value="Cancel">
					<input type="submit" name="add" value="Add">
				</div>
			"""
			callback: (result) ->
				return if result.add is 'Cancel'
				return unless result.file
				exec "#{self.path} add -r -q #{result.file}", (err, stdout, stderr) ->
					callback( err, stdout.split("\n").reverse()[1] )
				

	kill: ->
		@process?.stdin?.pause()
		spawn("taskkill", ["/pid", @process?.pid, '/f', '/t']) unless @os is 'darwin'
		@process?.kill?('SIGINT')
		@process = null
		@trigger( 'status', !!@process )