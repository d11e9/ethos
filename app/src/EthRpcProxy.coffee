http = require 'http'
express = require 'express'
bodyParser = require 'body-parser'
multer = require 'multer'
server = express()

contains = (arr, val) -> arr.indexOf( val ) >= 0

module.exports = (web3, config, dialogManager) ->

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

			source = request.headers.referer or request.headers.origin
			if !contains( rpcDomainWhitelist(), source ) and !contains( rpcDomainBlacklist(), source )
				dialogManager.newDialog
					title: "Ethos: Ethereum RPC Proxy"
					body: " Would you like to allow Ethereum RPC calls from: <pre>#{source}</pre> in the future."
					form: """
						<div class="center">
							<input type="submit" name="allow" value="Never">
							<input type="submit" name="allow" value="Not now">
							<input type="submit" name="allow" value="Yes">
						</div>
					"""
					callback: (result) =>
						if result.allow is 'Yes'
							config.flags['ethRpcProxyWhitelist'].push( source )
							config.saveFlag( 'ethRpcProxyWhitelist' )

						if result.allow is 'Never'
							config.flags['ethRpcProxyBlacklist'].push( source )
							config.saveFlag( 'ethRpcProxyBlacklist' )

						proxy_request.write( data ) if contains( rpcDomainWhitelist(), source )
						proxy_request.end()
			else
				proxy_request.write( data ) if contains( rpcDomainWhitelist(), source )
				proxy_request.end()

	server.use( bodyParser.json() )
	server.use( multer )
	server.use( bodyParser.urlencoded( extended: true ) )
	server.listen config.get('ethRpcProxyPort'), ->
		console.log "Eth RPC Proxy: running."