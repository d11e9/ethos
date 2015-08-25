http = require 'http'
express = require 'express'
bodyParser = require 'body-parser'
multer = require 'multer'
server = express()

rpcDomainWhitelist = []
rpcDomainBlacklist = []

contains = (arr, val) ->
	console.log( "Contains: ", arr, val)
	arr.indexOf( val ) >= 0 

module.exports = (web3, config) ->

	server.options '*', (request, response) ->
		response.header('Access-Control-Allow-Origin', '*')
		response.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
		response.header('Access-Control-Allow-Headers', 'Content-Type')
		response.end()

	server.post '/', (request, response) ->

		data = ''
		response.header('Access-Control-Allow-Origin', '*')
		response.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
		response.header('Access-Control-Allow-Headers', 'Content-Type')
		request.addListener 'data', (chunk) -> data += chunk
		request.addListener 'end', ->
			req =
				host: 'localhost'
				port: config.get('ethRpcPort')
				method: request.method
				headers:
					'Content-Type': 'application/x-www-form-urlencoded'
					'Content-Length': Buffer.byteLength(data)
			
			proxy_request = http.request req, (res) -> 
				res.on 'data', (chunk) -> response.write(chunk, 'binary')
				res.on 'end', (chunk) -> response.end()
				response.writeHead(res.statusCode, res.headers)

			if !contains( rpcDomainBlacklist, request.headers.origin ) and !contains( rpcDomainWhitelist, request.headers.origin )
				console.log rpcDomainWhitelist, rpcDomainBlacklist, config
				if window.confirm("Would you like to allow Ethereum RPC calls from: #{request.headers.origin} in the future.")
					rpcDomainWhitelist.push(request.headers.origin)
				else
					rpcDomainBlacklist.push(request.headers.origin)

			proxy_request.write( data ) if contains( rpcDomainWhitelist, request.headers.origin )
			proxy_request.end()

	server.use( bodyParser.json() )
	server.use( multer )
	server.use( bodyParser.urlencoded( extended: true ) )
	server.listen config.get('ethRpcProxyPort'), ->
		console.log "Eth RPC Proxy: running.", server