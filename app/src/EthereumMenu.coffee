path = require 'path'


module.exports = (gui) ->

	class Account
		constructor: (@address, @process, @config, @dialogManager) ->
			@web3 = @process.web3
			@submenu = new gui.Menu()
			@balanceItem = new gui.MenuItem
				label: "Balance: \u039E ..."
				enabled: false
			@submenu.append @balanceItem
			@submenu.append new gui.MenuItem
				label: "Unlock"
				click: @handleUnlock
			acc = @address
			@web3.eth.getBalance @address, (err, balance) =>
				return if err
				ethBalance = @web3.fromWei( balance )
				@balanceItem.label = "Balance: \u039E #{ethBalance}"

		getShortAddr: ->
			chars = 6
			"#{@address.substring(2,chars)}...#{@address.substring(@address.length - chars,@address.length)}"

		handleUnlock: =>
			@process.unlock( @address )

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
			@createConsoleItem()
			@process.on( 'connected', @update )
			@config.on( 'updated', @update )
			@update()

		update: =>
			@updateStatus()
			@updateAccounts()
			
		get: -> @rootItem

		createStatusItem: ->
			@toggle = new gui.MenuItem
				label: if @config.getBool('ethRemoteNode') then 'Connect' else 'Start'
				click: => @process.toggle()

			@status = new gui.MenuItem
				label: 'Status: Initializing'
				enabled: false

			@menu.append( @status )
			@menu.append( @toggle )

		createNewAccountItem: ->
			@newAccount = new gui.MenuItem
				label: 'New Account'
				enabled: !@config.getBool('ethRemoteNode')
				click: =>
					@process.newAccount()
					@updateAccounts()

			@menu.append( @newAccount )

		createImportItem: ->
			self = this
			@import = new gui.MenuItem
				label: 'Import Wallet'
				enabled: !@config.getBool('ethRemoteNode')
				click: => @process.importWallet()
					
			@menu.append( @import )

		createMiningItem: ->
			@mining = new gui.MenuItem
				label: 'Mining'
				enabled: !@config.getBool('ethRemoteNode')
				click: =>
					@process.toggleMining()
					@updateMining()

			@menu.append( @mining )

		createAccountsItem: ->
			@accounts = new gui.MenuItem
				label: 'Accounts'
				submenu: new gui.Menu()
			@menu.append( @accounts )

		createConsoleItem: =>
			@console = new gui.MenuItem
				label: "Console"
				click: => @process.console()
			@menu.append( @console )

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
				submenu: account.submenu

		updateAccounts: =>
			@web3.eth.getAccounts (err, accounts) =>
				if err or accounts.length is 0
					@accounts.label = "Accounts (0)"
					@accounts.enabled = false
					try
						@accounts.submenu.remove( item ) for item in @accounts.submenu.items
					catch e
						console.log(e) if @config.getBool( 'logging' )
				else if @accounts.submenu.items.length != accounts.length
					@accounts.label = "Accounts (#{accounts.length})"
					@accounts.enabled = true
					@accounts.submenu.remove( item ) for item in @accounts.submenu.items
					@accounts.submenu.append( @accountItem(acc) ) for acc in accounts

		updateStatus: =>
			remote = @config.getBool('ethRemoteNode')
			@web3.eth.getBlockNumber (err,block) =>
				@web3.net.getPeerCount (err, peers) =>
					status = if remote then 'Connected' else 'Running'
					status += " (#{peers or 0})"
					if err
						@status.label = "Status: Not #{status}"
						@toggle.label = if remote then 'Connect' else 'Start'
						@newAccount.enabled = false
						@import.enabled = false
						@mining.enabled = false
						@console.enabled = false
					else
						toggle = if remote then 'Disconnect' else 'Stop'
						@status.label = "Status: #{status} ##{block}"
						@toggle.label = toggle
						@newAccount.enabled = !remote
						@import.enabled = !remote
						@mining.enabled = !remote
						@console.enabled = !remote
					@updateAccounts()
					@updateMining()





