Backbone = require 'backbone'

module.exports = class Config extends Backbone.Model
	constructor: (@package)->
		@flags =
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
			ethRemoteNode: false
			ethRemoteNodeAddr: ""

		@saveDefaults()

	key: (flag) -> "ethosFlag_#{ flag }"

	load: ->
		for flag of @flags
			value = @get( flag )
			@flags[ flag ] = value if value?
		console.log "Config loaded: ", @flags

	saveDefaults: ->
		for flag of @flags
			@set( flag, @flags[flag] ) unless @get(flag)?

	get: (flag) ->
		value = window.localStorage.getItem( @key(flag) )
		console.log "getting config var: #{flag} value is: #{value}"
		value

	getBool: (flag) -> @get( flag ) is 'true'

	set: (flag, value) ->
		console.log( "Updating config: #{ flag }: #{ value }")
		@flags[flag] = value
		window.localStorage.setItem( @key(flag), @flags[flag] )
		@trigger( 'updated' )
