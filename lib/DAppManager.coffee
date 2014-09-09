
fs = require 'fs'
path = require 'path'
_ = require 'underscore'

dappConfig =
	ethos: { name: 'ethos', icon: 'cubes', key: '1Eth05PrivKey'}
	namereg: { name: 'namereg', icon: 'university' }
	coin: { name: 'coin', icon: 'database' }
	coins: { name: 'coins', icon: 'database' }
	exchange: { name: 'exchange', icon: 'university' }
	example: { name: 'example', icon: 'share', key: '1Ex4mp13PrivKey' }
	default: { name: 'ÐApp', icon: 'cube' }

class DAppManager 
	constructor: ({@rootDir}) ->
		@dirs = @getDirs()
		@dapps = @getDApps()
		@currentDApp = 'ethos'
		@dappConfig = dappConfig

	getDApps: ->
		dapps = {}
		withHtml = @dirs.filter (name) =>
			@getHtml( name ).length

		_.map withHtml, (name) =>
			#console.log( 'NAME: ', name)
			html = @getHtml( name )
			base = if dappConfig[name]
				dappConfig[name]
			else
				{ name: name, icon: dappConfig.default.icon }
			base.html = html[0]
			dapps[name] = base
		dapps

	getHtml: (folder) ->
		#console.log @rootDir, folder
		dir = path.join( @rootDir, folder )
		_.filter fs.readdirSync( dir ), (file) =>
			ext = path.extname( path.join( dir, file ) )
			ext is '.html'

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
			@winston.info 'URL: ' + req.url 
			@winston.info 'is asset: ' + @isAsset( req )
			# Assets will have extentions and no slashes
			if @isAsset( req ) and dappName isnt 'ethos'
				@winston.info( 'Serve ÐApp asset:' )
				res.sendFile( req.url, {root: "./dapps/#{ dappName }"} );
			else
				next()

	renderDApp: (req,res,next) =>
		if @isAsset( req )
			@winston.info( 'ÐApp asset.' + req.url )
		else
			url = req.params[0]
			dappName = url.split('/')[0]
			dapp = @dapps[ dappName ]
			@winston.info( 'Loading ÐApp: ' + dappName + ' is asset: ' + @isAsset( req ) )

			unless dapp
				#if no compatible dapp is availbe then defer to main router.
				next()
			else
				@currentDApp = dappName
				dapp.root = "#{ dappName }/#{ dapp.html }"
				res.sendFile( dapp.root, { root: './dapps' } )

module.exports = DAppManager