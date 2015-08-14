path = require 'path'


module.exports = (gui) ->

	class Account
		constructor: (@address, @process, @config) ->
			@web3 = @process.web3
			@submenu = new gui.Menu()
			@balanceItem = new gui.MenuItem
				label: "Balance: \u039E ..."
				enabled: false
			@submenu.append @balanceItem
			@submenu.append new gui.MenuItem
				label: "Unlock"
				click: @handleUnlock
			@submenu.append new gui.MenuItem
				label: "Send"
				click: @handleSend
			@submenu.append new gui.MenuItem
				label: "Receive"
				click: @handleReceive
			acc = @address
			@web3.eth.getBalance @address, (err, balance) =>
				return if err
				ethBalance = @web3.fromWei( balance )
				@balanceItem.label = "Balance: \u039E #{ethBalance}"

		getShortAddr: ->
			chars = 6
			"#{@address.substring(0,chars)}...#{@address.substring(@address.length - chars,@address.length)}"

		handleUnlock: =>
			@process.unlock( @address )

		handleSend: =>
			newWindowOptions =
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
			gui.Window.open( 'app://ethos/ipfs/wallet/index.html', newWindowOptions )

		handleReceive: =>
			clipboard = gui.Clipboard.get()
			clipboard.set(@address, 'text')
			window.alert( "Address copied to your clipboard.")

	class EthereumMenu
		constructor: ({@process, @config}) ->
			@menu = new gui.Menu()
			@rootItem = new gui.MenuItem
				label: 'Ethereum'
				submenu: @menu
			@web3 = @process.web3
			@createStatusItem()
			@createNewAccountItem()
			@createImportItem()
			@createAccountsItem()
			@createMiningItem()
			@process.on( 'status', @update )
			@update()

		update: =>
			@updateStatus()
			@updateAccounts()
			
		get: -> @rootItem

		createStatusItem: ->
			@toggle = new gui.MenuItem
				label: 'Start'
				click: => @process.toggle()

			@status = new gui.MenuItem
				label: 'Status: Initializing'
				enabled: false

			@menu.append( @status )
			@menu.append( @toggle )

		createNewAccountItem: ->
			@newAccount = new gui.MenuItem
				label: 'New Account'
				click: =>
					@process.newAccount()
					@updateAccounts()

			@menu.append( @newAccount )

		createImportItem: ->
			@import = new gui.MenuItem
				label: 'Import Wallet'
				click: =>
					chooser = window.document.querySelector('#addFile')
					chooser.addEventListener "change", (ev) =>
						filePath = ev.target.value
						@process.importWallet filePath, (err) ->
							window.alert( "Wallet imported successfully") unless err
						gui.Window.get().hide()
					gui.Window.get().show()
					chooser.click()
			@menu.append( @import )

		createMiningItem: ->
			@mining = new gui.MenuItem
				label: 'Mining'
				click: =>
					@process.toggleMining()
					@updateMining()

			@menu.append( @mining )

		createAccountsItem: ->
			@accounts = new gui.MenuItem
				label: 'Accounts'
				submenu: new gui.Menu()
			@menu.append( @accounts )


		updateMining: =>
			@web3.eth.getMining (err, mining) =>
				if err or !mining
					@mining.label = "Start Mining"
				else
					@mining.label = "Stop Mining"

		accountItem: (address) =>
			account = new Account(address, @process, @config)
			new gui.MenuItem
				label: account.getShortAddr()
				icon: "./app/images/lock-icon.png"
				submenu: account.submenu

		updateAccounts: =>
			@web3.eth.getAccounts (err, accounts) =>
				if err or !accounts.length
					@accounts.label = "Accounts (0)"
					@accounts.enabled = false
				else if @accounts.submenu.items.length != accounts.length
					@accounts.label = "Accounts (#{accounts.length})"
					@accounts.enabled = true
					@accounts.submenu.remove(item) for item in @accounts.submenu.items
					@accounts.submenu.append( @accountItem(acc) ) for acc in accounts

		updateStatus: =>
			@web3.eth.getBlockNumber (err,block) =>
				if err
					@status.label = "Status: Not Connected"
					@toggle.label = "Start"
					@newAccount.enabled = false
				else
					@status.label = "Status: Connected ##{block}"
					@toggle.label = "Stop"
					@newAccount.enabled = true
				@updateAccounts()
				@updateMining()





