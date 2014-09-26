do ->
	return if window.EthosInjectSkip

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


	window.jquery = jquery = require 'jquery'
	window.Ethereum = require './ethereumjs-lib/ethereum-min.js'
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

	window.eth =
		client: 'ethos'
		keys: ['asdasda']
		ready: (cb) ->
			console.log 'eth ready'
			window.onload = ->
				console.log 'window onload'
				try
					cb.call( window )
				catch err
					console.error( 'onload cb error', err )
			this
		getBalance: ->
			console.log 'eth getBalance'
			0
		stateAt: -> 
			console.log 'eth stateAt', arguments
			1
		transact: -> 
			console.log 'eth transact', arguments
			null
		watch: ->
			console.log 'eth watch', arguments
			changed: ->

		fromAscii: (x) -> 
			console.log 'eth fromAscii', arguments
			x.toString()

		toDecimal: (x) ->
			console.log 'eth toDecimal', arguments
			parseInt( x )

		secretToAddress: ->
			console.log 'eth secretToAddress', arguments
			'1sasasdasdafasd'

		getKey: (callback) ->
			client.call { jsonrpc: '2.0', method: 'getKey', params: [] }, (err, resp) -> 
				if !err and resp?.result
					console.log( "RPC getKey completed: #{ resp.result }." )
					callback?.call( window, null, resp.result )
				else
					console.error( "RPC getKey Failed.", err )
					callback?.call( window, err, null )

		dapps: (callback) ->
			client.call { jsonrpc: '2.0', method: 'dapps', params: [] }, (err, resp) -> 
				if !err and resp?.result
					console.log( "RPC Dapps completed: #{ resp.result }." )
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

	window.eth.ready ->
		console.log 'Ethos eth Ready.'

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

					eth.dapps (err, dapps) ->
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