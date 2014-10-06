do ->
	return if window.EthosInjectSkip
	try

		console.log "Ethos inject.coffee: ok", window
		window.EthosInjectSkip = true



		window.onerror = (errorMsg, url, lineNumber, column, errorObj) ->
			alert('Error: ' + errorMsg + ' Script: ' + url + ' Line: ' + lineNumber
			+ ' Column: ' + column + ' StackTrace: ' +  errorObj)

		document.addEventListener 'keyup', (e) ->
			if (e.keyCode == 'O'.charCodeAt(0) and e.ctrlKey) 
				console.log('open')
			else if (e.keyCode == 'S'.charCodeAt(0) and e.ctrlKey) 
				console.log('save')
			else if (e.keyCode == 'H'.charCodeAt(0) and e.ctrlKey) 
				console.log('home')
				window.location.href = 'http://eth:8080/ethos#home'

		window.jQuery = window.$ = $ = jquery = require 'jquery'
		window.Ethereum = require '../../lib/ethereumjs-lib/ethereum-min.js'
		window.WebTorrent = require '../../lib/webtorrent.min.js'

		polyeth = require( '../../lib/poly-eth/src/index.js' )
		window.eth = polyeth( require( '../../lib/ethereumjs/main.js' ).eth )
		
		url = require 'url'
		rpc = require 'node-json-rpc'


		client = new rpc.Client
			port: 7001
			host: '127.0.0.1'
			path: '/'
			strict: false

		rpc = (method, args, cb) ->
			args = [] unless args
			args = args[0] if args.length
			client.call( { jsonrpc: '2.0', method: method, params: args }, cb )

		client.call { jsonrpc: '2.0', method: 'ping', params: [] }, (err, resp) -> 
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
				client.call { jsonrpc: '2.0', method: 'dapps', params: [] }, (err, resp) -> 
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
		console.log( "Ethos Error (inject.bundle.js): ", err )