
global.Element = window.Element
global.document = window.document

HTML = require global.execPath "html.js"
HTML.ify(window.document.querySelector('html'));

_ = require global.execPath 'underscore'
$ = require global.execPath 'jquery'
Backbone = require global.execPath 'backbone'
Backbone.$ = $
Marionette = require global.execPath 'backbone.marionette'
md5 = require global.execPath 'js-md5'
identicon = require global.execPath 'jdenticon'
web3 = window.web3 = require global.execPath 'web3'

require './wallet.less'

class AccountView extends Marionette.ItemView
	className: 'account'
	template: _.template """
		<div class="image"><%= image %></div>
		<div class="address" title="<%- address %>"><%- address %></div>
		<div class="balance"><span class="symbol eth"></span> <span class="amount"><%- balance %></span></div>
	"""
	ui:
		image: '.image'

	onShow: ({@model}) ->
		@listenTo( @model, 'change', @render )
		@listenTo( @model, 'select': -> @trigger('select') )

	serializeData: ->
		address: @model.get('address')
		image: @model.get('image')
		balance: web3.fromWei( @model.get('balance'), 'ether' )

	triggers:
		'click': 'select'


class AccountsView extends Marionette.CollectionView
	className: 'accounts-view'
	childView: AccountView
	childEvents:
		'select': '_handleSelectAccountView'

	_handleSelectAccountView: (childView) ->
		@trigger('select:account', childView.model)

	

class Account extends Backbone.Model
	initialize: ({@address}) ->
		@set 'balance', 0
		@set 'image', identicon.toSvg( md5( @address ), 50 )
		@_updateBalance()

	select: ->
		@trigger('select', @)

	_updateBalance: ->
		web3.eth.getBalance @address, (err, balance) =>
			@set( 'balance', balance ) unless err

class Accounts extends Backbone.Collection

class NewTransaction extends Backbone.Model

class SendView extends Marionette.ItemView
	classname: "send-view"
	tagName: 'form'
	template: _.template """
		<div class="to-from">
			<label class="from"><span class="label">From: </span><%= from_img %><input type="text" disabled value="<%- from %>"></label>
			<label class="to"><span class="label">To: </span><%= to_img %><input type="text" value="<%- to %>"></label>
		</div>
		<div class="detail">
			<label class="amount"><span class="label">Amount: </span><input type="number"></label>
			<div class="gases">
				<label class="gas"><span class="label">Gas: </span><input type="number"></label>
				<label class="gas-price"><span class="label">Gas price: </span><input type="number"></label>
			</div>
		</div>
		<div class="actions">
			<button>Send</button>
		</div>
		
	"""
	initialize: ({model})->
		@model = model or new NewTransaction
			from: null
			to: null
			amount: null
			gas: null
			gasPrice: null
			data: null
	events:
		'change .to input': '_changeTo'

	ui:
		toInput: '.to input'

	onShow: ->
		@listenTo( @model, 'change', @render )
		@_changeTo()
			
	serializeData: ->
		from: @model?.get('from') or '<none>'
		from_img: identicon.toSvg( md5( @model?.get('from') or '' ), 50 ) 
		to: @model?.get('to') or '<none>'
		to_img:identicon.toSvg( md5( @model?.get('to') or '' ), 50 )

	updateSender: (account) ->
		@model.set( 'from', account.get('address'))

	updateTo: (address) ->
		@model.set( 'to', address)
		@ui.toInput.toggleClass( 'error', !web3.isAddress(address) )

	_changeTo: (ev) ->
		@updateTo( @ui.toInput.val() )



class TransactionView extends Marionette.ItemView
	className: 'transaction'
	template: _.template """
		<label class="from"><%= from_img %><span class="address" title="<%- from %>"><%- from %></span></label>
		<label class="separator"><span class="value"><span class="symbol eth"> </span><%- value %></span></label>
		<label class="to"><%= to_img %><span class="address" title="<%- to %>"><%- to %></span></label>
		<div class="details">
			<pre><%- txProperties %></pre>
		</div>
	"""
	ui:
		details: '.details'

	events:
		'click .address': '_handleAddressClick'
		'click': '_toggleDetails'
		'click .details': (ev) ->
			ev.preventDefault()
			false

	onShow: ->
		@listenTo( @model, 'updated', @render )

	serializeData: ->
		from: @model.get('from') or null
		from_img: identicon.toSvg( md5( @model.get('from') ), 50 )
		to: @model.get('to') or null
		to_img: identicon.toSvg( md5( @model.get('to') ), 50 ) or null
		value: web3.fromWei( @model.get('value'), 'ether' ) or null
		txProperties: JSON.stringify( @model.toJSON(), null,  2 )

	_toggleDetails: ->
		@$el.toggleClass('expanded')

	_handleAddressClick: (ev) =>
		ev.preventDefault()
		address = ev.target.innerHTML
		window.console.log "handle click addr:", address
		@trigger( 'select:address', address )
		false

class Transaction extends Backbone.Model
	initialize: (txProperties) ->
		web3.eth.getTransactionReceipt txProperties.hash, (err, resp) =>
			@set('contractAddress', resp.contractAddress )
			@trigger('updated')



class TransactionsView extends Marionette.CollectionView
	childView: TransactionView
	className: 'transactions-view'
	childEvents:
		'select:address': '_handleSelectAddress'
	initialize: ->
		@collection = new Backbone.Collection([])

	forAccount: (account) ->
		@collection.reset()
		@address = account.get('address')
		@_trawlBlocks( web3.eth.blockNumber )

	_trawlBlocks: (blockNumber) =>
		@_getTransactions( null, web3.eth.getBlock( blockNumber ) )
		setTimeout( (=> @_trawlBlocks( blockNumber - 1) ), 100) unless blockNumber is 1

	_getTransactions: (err, block) ->
		web3.eth.getTransaction( txHash, @_handleTransaction ) for txHash in block?.transactions

	_handleTransaction: (err, tx) =>
		@collection.add( new Transaction(tx) ) if tx?.to is @address or tx?.from is @address

	_handleSelectAddress: (childView, address) ->
		window.console.log "handle select address:", address, arguments
		@trigger( 'select:address', address)  


class AppView extends Marionette.LayoutView
	className: 'wallet-app-view'
	template: _.template """
		<div class="overlay"/>
		<div class="accounts"/>
		<div class="send"/>
		<div class="transactions"/>
	"""
	regions:
		accounts: '.accounts'
		overlay: '.overlay'
		send: '.send'
		transactions: '.transactions'

	initialize: ->
		@accountsCollection = new Accounts([])
		@accountsView = new AccountsView( collection: @accountsCollection )
		@sendView = new SendView()
		@transactionsView = new TransactionsView()

	onShow: ->
		setTimeout( @_statusCheck, 1000 )
		@_statusCheck()
		@accounts.show( @accountsView )
		@send.show( @sendView )
		@transactions.show( @transactionsView )
		@_fetchAccounts() if web3.isConnected()
		@listenTo( @accountsView, 'select:account', @_handleSelectAccount )
		@listenTo( @transactionsView, 'select:address', @_handleSelectAddress )

	_handleSelectAccount: (model)->
		@sendView.updateSender(model)
		@transactionsView.forAccount(model)

	_handleSelectAddress: (address) ->
		window.console.log "app view select address:", address
		@sendView.updateTo(address)

	_fetchAccounts: ->
		web3.eth.getAccounts (err, accounts) =>
			if err
				window.console.log err
			else
				@accountsCollection.add new Account( address: acc) for acc in accounts
				@accountsCollection.at(0).select()

	_statusCheck: =>
		if web3.isConnected()
			@overlay.empty()
		else
			@overlay.show( new Web3StatusOverlay() )

class Web3StatusOverlay extends Marionette.ItemView
	className: 'status-overlay'
	template: _.template """
		<p>Web3 connecting...</p>
	"""
	initialize: ->


$ ->
	appRegion = new Marionette.Region( el: window.document.body )
	appView = new AppView()
	global.wallet = appView
	appRegion.show( appView )