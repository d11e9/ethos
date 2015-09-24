Backbone = require 'backbone'
_ = require 'underscore'

module.exports = class Config extends Backbone.Model
	constructor: (@package)->
		@flags = {}
		@defaults =
			debug: false
			startup: true
			ethStart: true
			ipfsStart: true
			logging: true
			showAbout: true
			ethRpc: true
			ethRpcAddr: 'localhost'
			ethRpcPort: 9001
			ethRpcProxyPort: 8545
			ethRpcCorsDomain: "*"
			ethRpcProxyWhitelist: []
			ethRpcProxyBlacklist: []
			ethRemoteNode: false
			ethRemoteNodeAddr: ""
			ethRemoteNodePort: 8545
			ipfsDApps: []
			localDApps: []

		@saveDefaults()

	key: (flag) -> "ethosFlag_#{ flag }"

	load: ->
		for flag of @defaults
			value = @get( flag )
			@flags[ flag ] = value if value?
		console.log "Config loaded: ", @flags

	saveDefaults: (force) ->
		for flag of @defaults
			@set( flag, @defaults[flag] ) if force or !@get(flag)?

	get: (flag) ->
		try
			rawValue = window.localStorage.getItem( @key(flag) )
			value = JSON.parse( rawValue )
		catch
			console.log("Failed to parse config (#{ flag }) value: #{rawValue}" )
		value

	getBool: (flag) -> @get( flag ) is true

	set: (flag, value) ->
		@flags[flag] = value
		window.localStorage.setItem( @key(flag), JSON.stringify( @flags[flag] ) )
		@trigger( 'updated' )

	removeItem: (item, flag) ->
		@flags[flag] = _.without(@flags[flag], _.findWhere(@flags[flag], item))
		@saveFlag( flag )

	addItem: (item, flag) ->
		@flags[flag].push( item )
		@saveFlag( flag )

	saveFlag: (flag) ->
		@set( flag, @flags[flag] );
