Backbone = require 'backbone'

module.exports = class Config extends Backbone.Model
	constructor: ->
		@flags =
			startup: 1
			ethStart: 1
			ipfsStart: 1
			logging: 1
		@eth =
			ethRpcPort: 8545
			ethRpcCorsDomain: "*"

		@saveDefaults()

	key: (flag) -> "ethosFlag_#{ flag}"

	load: ->
		for flag of @flags
			value = @get( flag )
			@flags[ flag ] = value if value?
		console.log "Config loaded: ", @flags
			
	saveDefaults: ->
		for flag of @flags
			@set( flag, @flags[flag] ) unless @get(flag)?

	get: (flag) ->
		parseInt( window.localStorage.getItem( @key(flag) ), 10 ) or 0

	set: (flag, value) ->
		@flags[flag] = if value then 1 else 0
		window.localStorage.setItem( @key(flag), @flags[flag] )
