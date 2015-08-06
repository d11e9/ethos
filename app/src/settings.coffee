module.exports = (gui) ->
	console.log( "Ξthos settings: loading" )
	win = gui.Window.get()
	win.window.onload = ->
		console.log( "Ξthos settings initialized: ok" )