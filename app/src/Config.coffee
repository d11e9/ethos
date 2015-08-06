module.exports = class Config
	constructor: ->
		@flags =
			startup: true
			ethStart: true
			ipfsStart: true
		@saveDefaults()

	key: (flag) -> "ethosFlag_#{ flag}"

	load: ->
		for flag of @flags
			value = @get( flag )
			@flags[ flag ] = value if value? 
			
	saveDefaults: ->
		for flag of @flags
			@set( flag, @flags[flags] ) if @get(flag)?

	get: (flag) ->
		window.localStorage.getItem( @key(flag) )

	set: (flag, value) ->
		@flags[flag] = value
		window.localStorage.setItem( @key(flag), value )
