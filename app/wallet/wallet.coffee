
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


class AccountView extends Marionette.ItemView
	className: 'account'
	template: _.template """
		<div class="image"><%= image %></div>
		<span class="address"><%- address %></span>
		<span class="balance">&Xi; <%- balance %></span>
	"""
	ui:
		image: '.image'

	serializeData: ->
		address: @model.get('address')
		image: identicon.toSvg( md5( @model.get('address') ), 50 )
		balance: web3.fromWei( @model.get('balance'), 'ether' )

	initialize: ({@model}) ->
		@listenTo( @model, 'change', @render )

class AccountsView extends Marionette.CollectionView
	className: 'accounts-view'
	childView: AccountView
	

class Account extends Backbone.Model
	initialize: ({@address}) ->
		@set 'balance', 0
		@_updateBalance()

	_updateBalance: ->
		web3.eth.getBalance @address, (err, balance) =>
			@set( 'balance', balance ) unless err

class Accounts extends Backbone.Collection


class AppView extends Marionette.LayoutView
	className: 'wallet-app-view'
	template: _.template """
		<div class="accounts"/>
	"""
	regions:
		accounts: '.accounts'

	initialize: ->
		@accountsCollection = new Accounts([])

	onShow: ->
		@accounts.show( new AccountsView( collection: @accountsCollection ) )
		@_fetchAccounts()

	_fetchAccounts: ->
		web3.eth.getAccounts (err, accounts) =>
			if err
				window.console.log err
			else
				@accountsCollection.add new Account( address: acc ) for acc in accounts



$ ->
	appRegion = new Marionette.Region( el: window.document.body )
	appView = new AppView( web3: window.web3 )
	global.wallet = appView
	appRegion.show( appView )