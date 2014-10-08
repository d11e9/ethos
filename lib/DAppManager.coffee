
fs = require 'fs'
path = require 'path'
_ = require 'underscore'

dappConfig =
	ethos: { name: 'ethos', icon: 'cubes', key: '1Eth05PrivKey'}
	namereg: { name: 'namereg', icon: 'university' }
	coin: { name: 'coin', icon: 'database' }
	coins: { name: 'coins', icon: 'database' }
	exchange: { name: 'exchange', icon: 'university' }
	example: { name: 'example', icon: 'share-alt', key: '1Ex4mp13PrivKey' }
	default: { icon: 'cube' }


class DAppManager 
	constructor: ({@rootDir, @winston}) ->
		@dirs = @getDirs()
		@dapps = @getDApps()
		@currentDApp = 'ethos'
		@dappConfig = dappConfig

	getDApps: ->
		dapps = {}
		for folder in @dirs
			config = @getConfig( folder )
			config.html ?= @getHtml( folder )[0]
			if config.html
				dapps[folder] = config
		dapps

	getHtml: (folder) =>
		#console.log @rootDir, folder
		dir = path.join( @rootDir, folder )
		_.filter fs.readdirSync( dir ), (file) ->
			ext = path.extname( path.join( dir, file ) )
			ext is '.html'

	getConfig: (folder) =>
		dir = path.join( @rootDir, folder )
		configPath = "#{ dir }/dapp.json"
		config = _.defaults( dappConfig[ folder ] or { name: folder }, dappConfig.default )
		try
			configJson = fs.readFileSync( configPath, "utf8" )
			config = _.defaults( config, JSON.parse( configJson ) )
		catch err
			@winston.warn( "Unable to parse ÐApp config for: #{ folder }, using default." )
		config

	getDirs:  ->
		_.filter fs.readdirSync( @rootDir ), (file) =>
			return false if file[0] is '.'
			fs.statSync( "#{@rootDir}/#{file}" ).isDirectory()

	isAsset: (req) -> req.url.match( /\./ )?

	middleware: (app, winston) =>
		@app = app
		@winston = winston

		app.use( /^\/(.*)/i, @renderDApp )

		(req,res,next) =>
			dappName = @currentDApp;
			@winston.info "URL: #{ req.url } is asset: #{ @isAsset( req ) }"
			# Assets will have extentions and no slashes
			
			if @isAsset( req ) and dappName isnt 'ethos'
				@winston.info( "Serving ÐApp asset: #{ req.url }" )
				url = path.join( "./dapps/#{ dappName }", req.url )
				fs.stat url,  (err, stats) ->
					unless err
						size=stats
						console.log(size.size)
						res.sendFile( url )
					else
						res.send( "var error = '404: #{ url }';" )
			else
				next()

	renderDApp: (req,res,next) =>
		if @isAsset( req )
			@winston.info( 'ÐApp asset.' + req.url )
		else
			url = req.params[0]
			dappName = url.split('/')[0]
			dapp = @dapps[ dappName ]
			@winston.info( 'Loading ÐApp: ' + dappName + ' is dapp: ' + !!(@dapps[ dappName ] or dappName = 'ethos') )

			unless dapp
				#if no compatible dapp is availbe then defer to main router.
				next()
			else
				for dapp in @dapps
					console.log "checking for #{req.url} in #{dapp} ", dapps.assets
					if dapp.assets?.indexOf( req.url )
						console.log "found: ", req.url
					else
						console.log "--"
				@currentDApp = dappName
				dapp.root = "#{ dappName }/#{ dapp.html }"
				res.sendFile( dapp.root, { root: './dapps' } )

module.exports = DAppManager