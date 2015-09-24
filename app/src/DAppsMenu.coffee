_ = require global.execPath 'underscore'
Backbone = require global.execPath 'backbone'
path = require 'path'

module.exports = (gui) ->
	root = this
	class DAppsMenu extends Backbone.Model
		constructor: ({@eth, @ipfs, @config, @dialogManager}) ->
			self = this
			@win = window
			@menu = new gui.Menu()
			@dappWindows = []
			@rootItem = new gui.MenuItem
				label: '\u00D0Apps'
				submenu: @menu

			@newDappMenu =  new gui.Menu()

			@newDappMenu.append new gui.MenuItem
				label: 'From IPFS hash'
				click: =>
					@dialogManager.newDialog
						title: 'Ethos: Add \u00D0App'
						body: "Please provide the IPFS content hash and a name for this \u00D0App."
						form: """
							<input type="text" placeholder="Name" name="name">
							<input type="text" placeholder="IPFS Hash" name="hash">
							<div class="center">
								<input type="submit" name="add" value="Cancel">
								<input type="submit" name="add" value="Add">
							</div>
						"""
						callback: (result) ->
							return if result.add is 'Cancel'
							return unless result.hash and result.name
							self.addIPFSDApp( result.name, result.hash )


			@newDappMenu.append new gui.MenuItem
				label: 'Local File'
				click: =>
					@dialogManager.newDialog
						title: 'Ethos: Add \u00D0App'
						body: "Select the <em>index.html</em> file for your local \u00D0App and a name."
						form: """
							<input type="text" placeholder="Name" name="name"> <input type="file" name="file">
							<div class="center">
								<input type="submit" name="add" value="Cancel">
								<input type="submit" name="add" value="Add">
							</div>
						"""
						callback: (result) ->
							return if result.add is 'Cancel'
							return unless result.file and result.name
							self.addLocalDApp( result.name, result.file )
					

			@menu.append new gui.MenuItem
				label: 'Add \u00D0App'
				submenu: @newDappMenu

			@menu.append new gui.MenuItem
				label: 'Basic Wallet'
				click: => @openDApp('Basic Wallet', 'wallet')

			@menu.append new gui.MenuItem
				label: 'DApp List'
				click: => @openDApp('\u00D0App List', 'dapplist')

			for dapp in @config.get('ipfsDApps')
				do (dapp) =>
					@menu.append @getIPFSDAppMenu( dapp.name, dapp.hash )

			for dapp in @config.get('localDApps')
				do (dapp) =>
					@menu.append @getLocalDAppMenu( dapp.name, dapp.path )

		get: -> @rootItem
		closeAll: -> w.win.close(true) for w in @dappWindows

		getIPFSDAppMenu: (name, hash) =>
			self = this
			menu = new gui.Menu()
			menuItem = new gui.MenuItem
				label: name
				submenu: menu
			open = new gui.MenuItem
				label: 'Open'
				click: => @openDAppFromIPFSHash(name, hash)
			remove = new gui.MenuItem
				label: 'Remove'
				click: =>
					@dialogManager.newDialog
						title: 'Ethos: Remove \u00D0App'
						body: "Are you sure you want to remove the IPFS \u00D0App: <strong>#{ name }</strong> from Ethos? "
						form: """
							<div class="center">
								<input type="submit" name="remove" value="Cancel">
								<input type="submit" name="remove" value="Yes">
							</div>
						"""
						callback: (result) ->
							return if result.remove is 'Cancel'
							self.menu.remove( menuItem )
							self.removeIFPSDApp(name, hash )
			menu.append( open )
			menu.append( remove )
			menuItem

		getLocalDAppMenu: (name, path) =>
			self = this
			menu = new gui.Menu()
			menuItem = new gui.MenuItem
				label: name
				submenu: menu
			open = new gui.MenuItem
				label: 'Open'
				click: => @openDAppFromFolder(name, path)
			remove = new gui.MenuItem
				label: 'Remove'
				click: =>
					@dialogManager.newDialog
						title: 'Ethos: Remove \u00D0App'
						body: "Are you sure you want to remove the local \u00D0App: <strong>#{ name }</strong> from Ethos?"
						form: """
							<div class="center">
								<input type="submit" name="remove" value="Cancel">
								<input type="submit" name="remove" value="Yes">
							</div>
						"""
						callback: (result) ->
							return if result.remove is 'Cancel'
							self.menu.remove( menuItem )
							self.removeLocalDApp(name, path )
			menu.append( open )
			menu.append( remove )
			menuItem

		addIPFSDApp: (name,hash) ->
			@config.flags.ipfsDApps.push({name,hash})
			@config.saveFlag( 'ipfsDApps' )
			@menu.append @getIPFSDAppMenu( name, hash )
			@openDAppFromIPFSHash(name, hash)

		removeIFPSDApp: (name, hash) ->
			@config.flags.ipfsDApps = _.without(@config.flags.ipfsDApps, _.findWhere(@config.flags.ipfsDApps, {name, hash}))
			@config.saveFlag( 'ipfsDApps' )

		addLocalDApp: (name,path) ->
			@config.flags.localDApps.push({name,path})
			@config.saveFlag( 'localDApps' )
			@menu.append @getLocalDAppMenu( name, path )
			@openDAppFromFolder(name, path)

		removeLocalDApp: (name, path) ->
			@config.flags.localDApps = _.without(@config.flags.localDApps, _.findWhere(@config.flags.localDApps, {name, path}))
			@config.saveFlag( 'localDApps' )

		getWindowOptions: (name)->
			"inject-js-start": "node_modules/web3/dist/web3.js"
			"inject-js-end": "app/js/web3rpc.js"
			icon: "app/images/icon-tray.ico"
			title: name
			toolbar: @config.getBool( 'debug' )
			frame: true
			show: true
			focus: true
			show_in_taskbar: true
			width: 800
			height: 500
			position: "center"
			min_width: 400
			min_height: 200

		openDAppFromIPFSHash: (name, hash) ->
			gui.Shell.openExternal "http://#{ if @ipfs.connected then @ipfs.getGateway() else 'gateway.ipfs.io' }/ipfs/#{ hash }"

		openDAppFromFolder: (name, url) ->
			gui.Shell.openExternal( "http://localhost:8080/dapp/#{name}" )

		openDApp: (name, path) ->
			@handleOpenDApp
				name: name
				url: "app://ethos/app/#{path}/index.html"

		handleOpenDApp: ({name,url}) ->
			console.log "Opening DApp at #{ url }"
			gui.Window.open( url, @getWindowOptions(name) )

