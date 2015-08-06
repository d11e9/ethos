path = require 'path'

module.exports = (gui) ->
	class EthereumMenu
		constructor: ({@process}) ->
			@menu = new gui.Menu()
			@rootItem = new gui.MenuItem
				label: 'Ethereum'
				submenu: @menu
			@web3 = @process.web3
			@createStatusItem()
			@createNewAccountItem()
			@createAccountsItem()
			@update()

		update: =>
			@updateAccounts()
			@updateStatus()
			window.setTimeout( @update, 1000 )
			
		get: -> @rootItem

		createStatusItem: ->
			@status = new gui.MenuItem
				label: 'Status: Initializing'
				enabled: false
			@menu.append( @status )

		createNewAccountItem: ->
			@newAccount = new gui.MenuItem
				label: 'New Account'
				click: => @process.newAccount()
			@menu.append( @newAccount )

		createAccountsItem: ->
			@accounts = new gui.MenuItem
				label: 'Accounts'
				submenu: new gui.Menu()
			@menu.append( @accounts )

		updateAccounts: =>
			@web3.eth.getAccounts (err, accounts) =>
				if err or !accounts.length
					@accounts.label = "Accounts (0)"
					@accounts.enabled = false
				else if @accounts.submenu.items.length != accounts.length
					@accounts.label = "Accounts (#{accounts.length})"
					@accounts.enabled = true
					@accounts.submenu.remove(item) for item in @accounts.submenu.items
					@accounts.submenu.append( new gui.MenuItem( label: acc ) ) for acc in accounts

		updateStatus: =>
			@web3.eth.getBlockNumber (err,block) =>
				if err
					@status.label = "Status: Not Connected"
				else
					@status.label = "Block: ##{block}"





