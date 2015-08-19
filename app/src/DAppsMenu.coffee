module.exports = (gui) ->
	class DAppsMenu
		constructor: ({@eth, @ipfs, @config}) ->
			@menu = new gui.Menu()
			@rootItem = new gui.MenuItem
				label: '\u00D0Apps'
				submenu: @menu

			@menu.append new gui.MenuItem
				label: 'Add New'
				click: =>
					ipfsHash = window.prompt("Please enter the IPFS content hash of the \u00D0App to add.")
					console.log( "TODO: get DApp from ipfsHash: ", ipfsHash )

			@menu.append new gui.MenuItem
				label: 'Basic Wallet'
				click: => @openDApp('wallet')

		get: -> @rootItem
		getWindowOptions: ->
				icon: "app/images/icon-tray.ico"
				title: "Ethos"
				toolbar: @config.getBool( 'debug' )
				frame: true
				show: true
				show_in_taskbar: true
				width: 800
				height: 500
				position: "center"
				min_width: 400
				min_height: 200
				"new-instance": true
				"inject-js-start": "app/js/web3.js"
				"inject-js-end": "app/js/web3rpc.js"

		openDApp: (name) ->
			console.log "Opening #{name} DApp"
			w = gui.Window.open( "app://ethos/ipfs/#{name}/index.html", @getWindowOptions() )
			dappWin = gui.Window.get(w)
			dappWin.focus()
			console.log( dappWin )
			dappWin.on 'document-end', (frame) ->
				console.log "DApp document-end fired", frame
				dappWin.eval "alert('EVAL!')"
