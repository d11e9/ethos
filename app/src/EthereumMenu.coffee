path = require 'path'





module.exports = (gui) ->

	class Account
		constructor: (@address, @process) ->
			@submenu = new gui.Menu()
			@submenu.append new gui.MenuItem
				label: "Balance: #{}"
				enabled: false
			@submenu.append new gui.MenuItem
				label: "Unlock"
				click: @handleUnlock
			@submenu.append new gui.MenuItem
				label: "Send"
				click: @handleSend
			@submenu.append new gui.MenuItem
				label: "Receive"
				click: @handleReceive

		getShortAddr: ->
			chars = 6
			"#{@address.substring(0,chars)}...#{@address.substring(@address.length - chars,@address.length)}"

		handleUnlock: =>
			@process.unlock( @address, window.prompt("Enter passphrase to unlock account: #{ @address }") )

		handleSend: =>
			window.alert("TODO: Handle send")

		handleReceive: =>
			window.alert("TODO: Handle Receive")

	class EthereumMenu
		constructor: ({@process}) ->
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
			account = new Account(address, @process)
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





