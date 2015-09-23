
path = require 'path'

module.exports = (gui) ->
	console.log( "Ξthos settings: loading" )
	win = gui.Window.get()

	win.window.init = ->
		config = this.config

		rootDir = process.cwd()
		console.log "RootDir: #{ rootDir }"
		win.window.document.getElementById('rootDir').innerHTML = rootDir

		execDir = path.join( process.execPath, '../' )
		console.log "RootDir: #{ execDir }"
		win.window.document.getElementById('execDir').innerHTML = execDir

		version = config.package.version
		console.log "Version: #{ version }"
		win.window.document.getElementById('version').innerHTML = version

		clearBtn = win.window.document.getElementById('clearLocalstorage')
		clearBtn.addEventListener 'click', -> win.window.localStorage.clear()

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

			else if el.tagName is 'UL' or el.tagName is 'OL'
				val = config.get(flag)
				for i in val
					item = win.window.document.createElement( 'li' )
					if typeof i is 'object'
						item.innerHTML = JSON.stringify(i)
					else
						item.innerHTML = i
					el.appendChild( item )


		console.log( "Ξthos settings initialized: ok" )