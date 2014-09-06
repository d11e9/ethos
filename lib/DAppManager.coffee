
fs = require 'fs'
path = require 'path'
_ = require 'underscore'

iconMappings =
	namereg: { name: 'NameReg', icon: 'university' }
	coin: { name: 'GavCoin', icon: 'database' }
	coins: { name: 'Coins', icon: 'database' }
	exchange: { name: 'Exchange', icon: 'university' }
	default: { name: 'ÐApp', icon: 'cube' }

class DAppManager 
	constructor: ({@rootDir}) ->
		@dirs = @getDirs()
		@dapps = @getDApps()

	getDApps: ->
		withHtml = @dirs.map (name) =>
			@getHtml( name ).length

		withHtml.map (name) =>
			html = @getHtml( name )
			base = if iconMappings[name]
				iconMappings[name]
			else
				{ name: name, icon: iconMapings.default.icon }
			base.html = html[0]
			base

	getHtml: (folder) ->
		dir = path.join( @rootDir, folder )
		_.filter fs.readdirSync( dir ), (file) =>
			ext = path.extname( path.join( dir, file ) )
			ext is '.html'

	getDirs:  ->
		_.filter fs.readdirSync( @rootDir ), (file) =>
			return false if file[0] is '.'
			fs.statSync( "#{@rootDir}/#{file}" ).isDirectory()

module.exports = DAppManager