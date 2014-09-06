console.log "Ethos inject.coffee: ok"

jquery = require 'jquery'
url = require 'url'

window.eth =
	client: 'ethos'

if global?.require
	rpc = require 'node-json-rpc'
	client = new rpc.Client
		port: 7000
		host: '127.0.0.1'
		path: '/'
		strict: false

	rpcLog = (type,args) ->
		args = args[0] if args.length
		client.call
			jsonrpc: '2.0'
			method: type
			params: args

	window?.winston =
		error: -> rpcLog 'logError', arguments
		warn: -> rpcLog 'logWarn', arguments
		info: -> rpcLog 'logInfo', arguments

parseEthQuery = (href) ->
	query = url.parse( href, true ).query
	unless query.dapp
		query.dapp = if query.address
			'etherchain'
		else if query.ammount
			'walleth'
	query

jquery ->
	console.log 'jquery ready.'
	jquery( 'body' ).on 'click', '[href]', (ev) ->
		console.log 'href click'

		href = jquery( this ).attr 'href'
		ethIntent = href.match /^:eth\?(.*)/
		query = parseEthQuery href

		console.log this

		if ethIntent
			follow = !window.confirm "Open link in ÐApp: #{ query.dapp }"
			if follow
				ev.preventDefault()
				false

console.log "Ethos inject end: ok."