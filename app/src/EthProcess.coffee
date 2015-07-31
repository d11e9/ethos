path = require 'path'
fs = require 'fs'
cp = require 'child_process'
spawn = cp.spawn
Backbone = require 'backbone'

module.exports = class EthProcess extends Backbone.Model
	constructor: ({@os, ext}) ->
		@process = null
		@path = path.join( process.cwd(), "./bin/#{ @os }/geth/geth#{ ext }")
		@datadir = path.join( process.cwd(), './eth')
		@genesis_block = path.join( process.cwd(), './app/', 'genesis_block.json')
		fs.chmodSync( @path, '755') if @os is 'darwin'

	start: ->
		console.log( @path, @datadir, @genesis_block )
		@process = spawn( @path, ['--networkid', '1234234', '--genesis', @genesis_block, '--datadir', @datadir, '--rpc', '--shh'] )

		@process.on 'close', (code) =>
			console.log('Geth Exited with code: ' + code)
			@kill()
		
		@process.stdout.on 'data', (data) =>
			console.log('geth stdout: ' + data)
			@trigger 'status', !!@process

		@process.stderr.on 'data', (data) =>
			console.log('geth stderr: ' + data)
			@trigger 'status', !!@process


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
		@trigger 'status', !!@process