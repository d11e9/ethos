
path = require 'path'

module.exports = (gui) ->
	console.log( "Ξthos settings: loading" )
	win = gui.Window.get()

	win.window.init = ->
		config = this.config

		config.on 'updated', -> win.window.location.reload()

		rootDir = process.cwd()
		console.log "RootDir: #{ rootDir }"
		win.window.document.getElementById('rootDir').innerHTML = rootDir

		execDir = path.join( process.execPath, '../' )
		console.log "execDir: #{ execDir }"
		win.window.document.getElementById('execDir').innerHTML = execDir

		version = config.package.version
		console.log "Version: #{ version }"
		win.window.document.getElementById('version').innerHTML = version

		clearBtn = win.window.document.getElementById('reset')
		clearBtn.addEventListener 'click', (ev) ->
			ev.preventDefault()
			config.saveDefaults( true )

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
				do (flag) ->
					val = config.get(flag)
					for i in val
						item = win.window.document.createElement( 'li' )
						remove = win.window.document.createElement( 'a' )
						remove.href = "#"
						remove.className = 'remove'
						remove.title = 'Remove item'
						remove.innerHTML = 'x'
						remove.addEventListener 'click', (ev) ->
							ev.preventDefault()
							config.removeItem( i, flag )

						if typeof i is 'object'
							item.innerHTML = JSON.stringify(i)
						else
							item.innerHTML = i
						item.appendChild( remove )
						el.appendChild( item )


		console.log( "Ξthos settings initialized: ok" )