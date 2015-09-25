
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
			<label class="from">
				<span class="label">From: </span>
				<%= from_img %>
				<input type="text" disabled value="<%- from %>">
			</label>
			<label class="to">
				<span class="label">To: </span>
				<%= to_img %>
				<input type="text" value="<%- to %>">
			</label>
		</div>
		<div class="detail">
			<label class="value">
				<span class="label">Value: </span>
				<input type="number" value="<%- value %>">
			</label>
			<div class="gases">
				<label class="gas">
					<span class="label">Gas: </span>
					<input type="number" value="<%- gas %>">
					<a href="#">Estimate gas cost</a>
				</label>
				<label class="gasPrice">
					<span class="label">Gas price: </span>
					<input type="number" value="<%- gasPrice %>">
					<a href="#">Reccomend gas price</a>
				</label>
			</div>
			<div class="other">
				<label class="data">
					<span class="label">Data: </span>
					<textarea><%- data %></textarea>
				</label>
			</div>
		</div>
		<div class="actions">
			<button>Get Raw transaction</button>
			<button>Send transaction</button>
		</div>
		
	"""

	events:
		'change .to input': '_changeTo'
		'change .value input': '_changeValue'
		'change .gas input': '_changeGas'
		'change .gasPrice input': '_changeGasPrice'
		'change .data textarea': '_changeData'
		'click .gas a': '_getGasEstimate'
		'click .gasPrice a': '_getGasPrice'

	ui:
		toInput: '.to input'
		valueInput: '.amount input'
		gasInput: '.gas input'
		gasPriceInput: '.gasPrice input'
		dataInput: '.data textarea'

	modelEvents:
		'change': 'render'
			
	serializeData: ->
		from: @model.get('from')
		from_img: identicon.toSvg( md5( @model.get('from') or '' ), 50 ) 
		to: @model.get('to') or ''
		to_img: identicon.toSvg( md5( @model.get('to') or '' ), 50 )
		value: @model.get('value') or 0
		gas: @model.get('gas') or 0
		gasPrice: @model.get('gasPrice') or 0
		data: @model.get('data') or ''

	updateSender: (account) ->
		@model.set( 'from', account.get('address'))

	_changeTo: (ev)->
		@model.set( 'to', ev.target.value )
		@ui.toInput.toggleClass( 'error', !web3.isAddress(@ui.toInput.val()) )

	_changeValue: (ev)->
		@model.set( 'value', ev.target.value )
		#@ui.toInput.toggleClass( 'error', !web3.isAddress(@ui.amountInput.val()) )

	_changeGas: (ev)->
		@model.set( 'gas', ev.target.value )

	_changeGasPrice: (ev)->
		@model.set( 'gasPrice', ev.target.value )

	_changeData: (ev)->
		@model.set( 'data', ev.target.value )

	_getGasPrice: ->
		web3.eth.getGasPrice (err, gasPrice) =>
			@model.set( 'gasPrice', gasPrice ) unless err

	_getGasEstimate: ->
		tx =
			to: @model.get('to')
			from: @model.get('from')
			value: @model.get('value')
			data: @model.get('data')

		web3.eth.estimateGas tx, (err, gas) =>
			window.console.log "gas for: ", tx, ' is: ', gas
			@model.set('gas', gas ) unless err




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
		@sendView = new SendView
			model: new NewTransaction
				from: null
				to: null
				value: null
				gas: null
				gasPrice: null
				data: null

	onShow: ->
		setTimeout( @_statusCheck, 1000 )
		@_statusCheck()
		@accounts.show( @accountsView )
		@send.show( @sendView )
		@_fetchAccounts() if web3.isConnected()
		@listenTo( @accountsView, 'select:account', @_handleSelectAccount )

	_handleSelectAccount: (model)->
		@sendView.updateSender(model)

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