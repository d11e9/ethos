rpc = require 'node-json-rpc'

client = new rpc.Client
	port: 8080
	host: 'eth'
	path: '/ethos/api'
	strict: false

handler = (method) ->
	({params} = {}, callback) ->
		params ?= []
		callback ?= ->
		console.log('RPC Client calling method: ', method)
		client.call { jsonrpc: '2.0', method, params, id: 1 }, callback 

module.exports =
	ping: handler( 'ping' )
	dapps: handler( 'dapps' )
	showDev: handler( 'showDev' )
	dialog: handler( 'dialog' )
	logError: handler( 'logError' )