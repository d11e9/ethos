
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

	initialize: ({@model}) ->
		@listenTo( @model, 'change', @render )

	serializeData: ->
		address: @model.get('address')
		image: identicon.toSvg( md5( @model.get('address') ), 50 )
		balance: @model.web3.fromWei( @model.get('balance'), 'ether' )


class AccountsView extends Marionette.CollectionView
	className: 'accounts-view'
	childView: AccountView
	

class Account extends Backbone.Model
	initialize: ({@address,@web3}) ->
		@set 'balance', 0
		@_updateBalance()

	_updateBalance: ->
		@web3.eth.getBalance @address, (err, balance) =>
			@set( 'balance', balance ) unless err

class Accounts extends Backbone.Collection


class AppView extends Marionette.LayoutView
	className: 'wallet-app-view'
	template: _.template """
		<div class="overlay"/>
		<div class="accounts"/>
		<div class="send"/>
	"""
	regions:
		accounts: '.accounts'
		overlay: '.overlay'

	initialize: ({@web3})->
		@accountsCollection = new Accounts([])

	onShow: ->
		setTimeout( @_statusCheck, 1000 )
		@_statusCheck()
		@accounts.show( new AccountsView( collection: @accountsCollection ) )
		@_fetchAccounts() if @web3.isConnected()

	_fetchAccounts: ->
		@web3.eth.getAccounts (err, accounts) =>
			if err
				window.console.log err
			else
				@accountsCollection.add new Account( address: acc, web3: @web3 ) for acc in accounts

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