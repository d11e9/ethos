module.exports = (gui) ->
	class DAppsMenu
		constructor: ({@eth, @ipfs, @config}) ->
			@menu = new gui.Menu()
			@dappWindows = []
			@rootItem = new gui.MenuItem
				label: '\u00D0Apps'
				submenu: @menu

			@newDapp =  new gui.Menu()

			@newDapp.append new gui.MenuItem
				label: 'From IPFS hash'
				click: =>
					ipfsHash = window.prompt("Please enter the IPFS content hash of the \u00D0App to add.")
					console.log( "TODO: get DApp from ipfsHash: ", ipfsHash )

			@newDapp.append new gui.MenuItem
				label: 'Local Folder'
				click: =>
					@ipfs.addFolder (err, resp) ->
						console.log( "TODO: Load dapps from filesystem via ipfs ", arguments )

			@menu.append new gui.MenuItem
				label: 'Add \u00D0App'
				submenu: @newDapp

			@menu.append new gui.MenuItem
				label: 'Basic Wallet'
				click: => @openDApp('wallet')

			@menu.append new gui.MenuItem
				label: 'Psst'
				click: => @openDAppFromIPFSHash('QmdQgdt5yQTSCgAhiFBc3RfoxDCJ1ho2PpRDtf2tDb7HNY')

		get: -> @rootItem
		closeAll: -> w.close(true) for w in @dappWindows
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
				"inject-js-end": "app/js/web3-provider-setup.js"

		openDAppFromIPFSHash: (hash) ->
			url = "http://#{ @ipfs.getGateway() }/ipfs/#{ hash }"
			console.log "Opening #DApp at #{url}", 
			@dappWindows.push( gui.Window.open( url, @getWindowOptions() ))

		openDApp: (name) ->
			console.log "Opening #{name} DApp"
			@dappWindows.push( gui.Window.open( "app://ethos/ipfs/#{name}/index.html", @getWindowOptions() ) )

