
fs = require 'fs'
path = require 'path'
_ = require 'underscore'

iconMappings =
	namereg: { name: 'namereg', icon: 'university' }
	coin: { name: 'coin', icon: 'database' }
	coins: { name: 'coins', icon: 'database' }
	exchange: { name: 'exchange', icon: 'university' }
	default: { name: 'ÐApp', icon: 'cube' }

class DAppManager 
	constructor: ({@rootDir}) ->
		@dirs = @getDirs()
		@dapps = @getDApps()

	getDApps: ->
		dapps = {}
		withHtml = @dirs.filter (name) =>
			@getHtml( name ).length

		_.map withHtml, (name) =>
			#console.log( 'NAME: ', name)
			html = @getHtml( name )
			base = if iconMappings[name]
				iconMappings[name]
			else
				{ name: name, icon: iconMappings.default.icon }
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

module.exports = DAppManager