
path = require 'path'

module.exports = (gui) ->
	console.log( "Ξthos settings: loading" )
	win = gui.Window.get()
	config = global.ethos

	win.window.onload = ->

		rootDir = process.cwd()
		console.log "RootDir: #{ rootDir }"
		win.window.document.getElementById('rootDir').innerHTML = rootDir

		execDir = path.join( process.execPath, '../' )
		console.log "RootDir: #{ execDir }"
		win.window.document.getElementById('execDir').innerHTML = execDir

		version = config.package.version
		console.log "Version: #{ version }"
		win.window.document.getElementById('version').innerHTML = version

		for flag of config.flags
			el = win.window.document.getElementById( flag )
			continue unless el
			console.log flag, config.get(flag), el
			
			if el.type is 'checkbox'
				el.checked = config.getBool(flag)
				el.addEventListener 'change', (ev) ->
					config.set( ev.target.id, ev.target.checked )

			else if el.type is 'text' or el.type is 'number'
				el.value = config.get(flag)
				el.addEventListener 'change', (ev) ->
					config.set( ev.target.id, ev.target.value )

		console.log( "Ξthos settings initialized: ok" )