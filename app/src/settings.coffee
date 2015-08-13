
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

		for key of config.eth
			el = win.window.document.getElementById( key )
			console.log key, config.eth[key]
			el.value = config.eth[key]
			el?.addEventListener 'change', (ev) ->
				console.log( "Updated: ", ev.target.id, ev.target.value )

		updateEthButton = win.window.document.querySelector('.eth button')
		updateEthButton.onclick = (ev) ->
			for key of config.eth
				el = win.window.document.getElementById( key )
				config.eth[key] = el.value
			config.trigger('restartEth')
			console.log( "TODO: Update eth settings and restart")

		console.log( "Ξthos settings initialized: ok" )