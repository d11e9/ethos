do ->
	return if window.EthosInjectSkip
	try

		console.log "Ethos inject.coffee: ok"
		window.EthosInjectSkip = true
		window.require = ->

		window.onerror = (errorMsg, url, lineNumber, column, errorObj) ->
			errString = "Error: #{ errorMsg } Script: #{ url } Line: #{ lineNumber } Column: #{ column } StackTrace: #{ errorObj} ";
			client.call { jsonrpc: '2.0', method: 'logError', params: [errString], id: 5 }, (err, resp) -> 
				console.log( 'Error logged via RPC.', arguments )
			
			alert( errString )

		document.addEventListener 'keyup', (e) ->
			if (e.keyCode == 'O'.charCodeAt(0) and e.ctrlKey) 
				console.log('open')
			else if (e.keyCode == 'S'.charCodeAt(0) and e.ctrlKey) 
				console.log('save')
			else if (e.keyCode == 'H'.charCodeAt(0) and e.ctrlKey) 
				console.log('home')
				window.location.href = 'http://eth:8080/ethos#home'

		url = require 'url'
		rpc = require 'node-json-rpc'
		window.jQuery = window.$ = $ = jquery = require 'jquery'
		window.Ethereum = require '../../lib/ethereumjs-lib/ethereum-min.js'
		window.WebTorrent = require '../../lib/webtorrent.min.js'

		polyeth = require( '../../lib/poly-eth/src/index.js' )
		nativeEth = require( '../../lib/ethereumjs/main.js' ).eth
		window.eth = polyeth( nativeEth )

		# Intercept getKey API
		origGetKey = window.eth.getKey
		window.eth.getKey = (cb) ->

			client.call { jsonrpc: '2.0', method: 'dialog', params: [], id: 4 }, (err, resp) -> 
				console.log( 'rpc ping dialog', arguments )

			# Private keys for DApps are set in local storage
			# If none exits then fallback to requesting it from native eth object
			# TODO: dont fallback, generate a new key clientside.
			key = localStorage['dappKey']
			unless key
				try
					origGetKey (err, key) ->
						localStorage['dappKey'] = key unless err
						cb( err, key )
				catch err
					console.log err, this
			else
				console.log "DApp private key loaded from localStorage"
				cb( null, key )

		client = new rpc.Client
			port: 8080
			host: 'eth'
			path: '/ethos/api'
			strict: false

		rpc = (method, args, cb) ->
			args = [] unless args
			args = args[0] if args.length
			client.call( { jsonrpc: '2.0', method: method, params: args, id: 0 }, cb )

		client.call { jsonrpc: '2.0', method: 'ping', params: [], id: 1 }, (err, resp) -> 
			if !err and resp?.result
				console.log( "RPC Ping completed: #{ resp.result }." )
			else
				console.error( "RPC Ping Failed.", err )

		window?.winston =
			error: -> rpc( 'logError', arguments )
			warn: -> rpc( 'logWarn', arguments )
			info: -> rpc( 'logInfo', arguments )


		window.wtClient = new window.WebTorrent()
		# window.wtClient.add({
		# 	infoHash: '4fd267cd8c4fac0bae9f317bb051b383e0c558a1',
		# 	announce: [ 'wss://tracker.webtorrent.io' ]
		# }, (torrent) -> 
		# 	console.log "WebTorrent Check success: ", !!torrent
		# 	console.log "Torrent: ", torrent
		# )

		# Ethos Specific RPC
		window.ethos = 
			dapps: (callback) ->
				client.call { jsonrpc: '2.0', method: 'dapps', params: [], id: 3 }, (err, resp) -> 
					if !err and resp?.result
						console.log( "RPC Dapps completed:", resp.result )
						callback?.call( window, null, resp.result )
					else
						console.error( "RPC Dapps Failed.", err )
						callback?.call( window, err, null )

		parseEthQuery = (href) ->
			query = url.parse( href, true ).query
			unless query.dapp
				query.dapp = if query.address
					'etherchain'
				else if query.ammount
					'walleth'
			query

		jquery ->
			try
				console.log 'Ethos attaching URI Intent handlers.'
				jquery( 'body' ).on 'click', '[href]', (ev) ->
					href = jquery( this ).attr 'href'
					console.log 'href click: ' + href
					ethIntent = href.match /^:eth\?(.*)/
					query = parseEthQuery?( href )

					if ethIntent
						ev.preventDefault()

						ethos.dapps (err, dapps) ->
							dapps = Object.keys( dapps )
							if !err and dapps?.indexOf( query.dapp ) >= 0
								console.log('Dapp Installed open' )
								window.location = "/#{query.dapp}"
							else
								follow = window.confirm "Open link in ÐApp: #{ query.dapp }"
								window.location = "/#{query.dapp}" if follow
							console.log( 'clicked: ', query, ' have: ', dapps)
						false
					else
						true

			catch err
				window.winston?.error err

		console.log "Ethos inject end: ok."

	catch err
		console.log( "Ethos Error (inject.bundle.js): ", err.message, err )