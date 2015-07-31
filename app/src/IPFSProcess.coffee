path = require 'path'
cp = require 'child_process'
spawn = cp.spawn
Backbone = require 'backbone'

module.exports = class IPFSProcess extends Backbone.Model
	constructor: ({os, ext}) ->
		@process = null
		@path = path.join( process.cwd(), "./bin/#{ os }/ipfs/ipfs#{ ext }")

	start: ->
		@process =  spawn( @path, ['daemon', '--init'] )

		@process.on 'close', (code) =>
			console.log('IFPS Exited with code: ' + code)
			@kill()
		
		@process.stdout.on 'data', (data) =>
			console.log('IFPS stdout: ' + data)
			@trigger 'status', !!@process

		@process.stderr.on 'data', (data) =>
			console.log('IFPS stderr: ' + data)
			@trigger 'status', !!@process


	toggle: ->
		if @process
			@kill()
		else
			@start()
	kill: ->
		@process?.stdin?.pause()
		spawn("taskkill", ["/pid", @process?.pid, '/f', '/t'])
		@process?.kill?('SIGINT')
		@process = null
		@trigger 'status', !!@process