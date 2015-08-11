
module.exports = (gui) ->
	console.log( "Ξthos settings: loading" )
	win = gui.Window.get()
	config = global.ethos

	win.window.onload = ->
		for flag of config.flags
			el = win.window.document.getElementById( flag )
			console.log flag, !!config.get(flag), el
			el?.checked = !!config.get(flag)
			el?.addEventListener 'change', (ev) ->
				config.set( ev.target.id, ev.target.checked )
				console.log( "Updated: ", ev.target.id, ev.target.checked )

		console.log( "Ξthos settings initialized: ok" )