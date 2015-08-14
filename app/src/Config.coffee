Backbone = require 'backbone'

module.exports = class Config extends Backbone.Model
	constructor: ->
		@flags =
			startup: true
			ethStart: true
			ipfsStart: true
			logging: true
			ethRpc: true
			ethRpcAddr: 'localhost'
			ethRpcPort: 8545
			ethRpcCorsDomain: "*"
			ethRemoteNode: true
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

	get: (flag) -> window.localStorage.getItem( @key(flag) )

	getBool: (flag) -> @get( flag ) is 'true'

	set: (flag, value) ->
		console.log( "Updating config: #{ flag }: #{ value }")
		@flags[flag] = value
		window.localStorage.setItem( @key(flag), @flags[flag] )
