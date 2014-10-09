
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

	getJade: (folder) =>
		#console.log @rootDir, folder
		dir = path.join( @rootDir, folder )
		_.filter fs.readdirSync( dir ), (file) ->
			ext = path.extname( path.join( dir, file ) )
			ext is '.jade'

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
		@winston = winston

		app.use( /^\/(.*)/i, @renderDApp )

		(req,res,next) =>
			dappName = @currentDApp
			winston = @winston
			# Assets will have extentions and no slashes
			
			if @isAsset( req ) and dappName in _( @dapps ).keys()
				root = "./dapps/#{ dappName }"
				url = path.join( root, req.url )
				fs.stat url,  (err, stats) ->
					unless err
						winston.info( "ÐApp Middleware, Serving ÐApp (#{dappName}) asset: #{ req.url }" )
						res.sendFile( req.url, root: root )
					else
						winston.error( "ÐApp Middleware, Error serving asset for ÐApp: #{ url }")
						res.send( "var error = '404: #{ url }';" )
			else
				next()

	renderDApp: (req,res,next) =>
		url = req.params[0]
		dappName = url.split('/')[0]
		dapp = @dapps[ dappName ]

		unless dapp
			#if no compatible dapp is available then defer to main router.
			next()
		else
			@currentDApp = dappName
			dapp.url = "#{ dappName }/#{ dapp.html }"
			@winston.info( "Serving ÐApp (#{ dapp.name }) html file: #{ dapp.url }" )
			res.sendFile( dapp.url, root: './dapps' )

module.exports = DAppManager