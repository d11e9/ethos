
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
		balance: @model.web3.fromWei( @model.get('balance'), 'ether' )

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
	initialize: ({@address,@web3}) ->
		@set 'balance', 0
		@set 'image', identicon.toSvg( md5( @address ), 50 )
		@_updateBalance()

	select: ->
		@trigger('select', @)

	_updateBalance: ->
		@web3.eth.getBalance @address, (err, balance) =>
			@set( 'balance', balance ) unless err

class Accounts extends Backbone.Collection

class NewTransaction extends Backbone.Model

class SendView extends Marionette.ItemView
	classname: "send-view"
	tagName: 'form'
	template: _.template """
		<h2 class="title">Send Transaction</h2>
		<div class="to-from">
			<label class="from">From: <%= from_img %><input type="text" disabled value="<%- from %>"></label>
			<label class="to">To: <input type="text"></label>
		</div>
		<div class="costs">
			<label class="amount">Amount: <input type="number"></label>
			<label class="gas">Gas: <input type="number"></label>
			<label class="gas-price">Gas price: <input type="number"></label>
		</div>
	"""
	initialize: ({model})->
		@model = model or new NewTransaction
			from: null
			to: null
			amount: null
			
	serializeData: ->
		from: @model?.get('from') or '<none>'
		from_img: @model?.get('from_img') or ''

	updateSender: (account) ->
		@model.set( 'from', account.get('address'))
		@model.set( 'from_img', account.get('image'))
		@render()


class TransactionView extends Marionette.ItemView
	className: 'transaction'
	template: _.template """
		<label class="from"><%= from_img %><span class="address"><%- from %></span></label>
		<label class="separator"><span class="value"><span class="symbol eth"> </span><%- value %></span></label>
		<label class="to"><%= to_img %><span class="address"><%- to %></span></label>
		<div class="details">
			<pre><%- txProperties %></pre>
		</div>
	"""
	ui:
		details: '.details'

	events:
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

class Transaction extends Backbone.Model
	initialize: (txProperties) ->
		web3.eth.getTransactionReceipt txProperties.hash, (err, resp) =>
			@set('contractAddress', resp.contractAddress )
			@trigger('updated')



class TransactionsView extends Marionette.CollectionView
	childView: TransactionView
	className: 'transactions-view'
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

	initialize: ({@web3})->
		@accountsCollection = new Accounts([])
		@accountsView = new AccountsView( collection: @accountsCollection )
		@sendView = new SendView()
		@transactionsView = new TransactionsView()
		@listenTo( @accountsView, 'select:account', @_handleSelectAccount )

	onShow: ->
		setTimeout( @_statusCheck, 1000 )
		@_statusCheck()
		@accounts.show( @accountsView )
		@send.show( @sendView )
		@transactions.show( @transactionsView )
		@_fetchAccounts() if @web3.isConnected()

	_handleSelectAccount: (model)->
		@sendView.updateSender(model)
		@transactionsView.forAccount(model)

	_fetchAccounts: ->
		@web3.eth.getAccounts (err, accounts) =>
			if err
				window.console.log err
			else
				@accountsCollection.add new Account( address: acc, web3: @web3 ) for acc in accounts
				@accountsCollection.at(0).select()

	_statusCheck: =>
		if @web3.isConnected()
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
	appView = new AppView({web3})
	global.wallet = appView
	appRegion.show( appView )