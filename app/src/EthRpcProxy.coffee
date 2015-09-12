http = require 'http'
express = require 'express'
bodyParser = require 'body-parser'
multer = require 'multer'
server = express()



contains = (arr, val) -> arr.indexOf( val ) >= 0


requestRPCAccess = (path) ->
	notification = new window.Notification "Ethos",
		body: "The page at #{path} is requesting RPC access to your Ethereum Node. Allow?"
	notification.onclick ->
		notification.close()


module.exports = (web3, config) ->

	rpcDomainWhitelist = -> config.get('ethRpcProxyWhitelist')
	rpcDomainBlacklist = -> config.get('ethRpcProxyBlacklist')

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

			if !contains( rpcDomainBlacklist(), request.headers.origin ) and !contains( rpcDomainWhitelist(), request.headers.origin )
				console.log request
				if window.confirm("Would you like to allow Ethereum RPC calls from: #{request.headers.origin} in the future.")
					config.flags['ethRpcProxyWhitelist'].push( request.headers.origin )
					config.saveFlag( 'ethRpcProxyWhitelist' )
				else
					config.flags['ethRpcProxyBlacklist'].push( request.headers.origin )
					config.saveFlag( 'ethRpcProxyBlacklist' )
			console.log data
			proxy_request.write( data ) if contains( rpcDomainWhitelist(), request.headers.origin )
			proxy_request.end()

	server.use( bodyParser.json() )
	server.use( multer )
	server.use( bodyParser.urlencoded( extended: true ) )
	server.listen config.get('ethRpcProxyPort'), ->
		console.log "Eth RPC Proxy: running."