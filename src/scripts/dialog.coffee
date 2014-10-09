$ = jquery = require 'jquery'
_ = require 'underscore'

Backbone = require 'backbone'
Backbone.$ = $
Marionette = require 'backbone.marionette'
querystring = require 'querystring'


class Dialog extends Backbone.Model
	defaults:
		title: 'Welcome Default'
		body: '<p>Default Welcome to Ethos an Ethereum Browser.</p>'

class DialogView extends Marionette.ItemView
	template: _.template """
		<header>
			<i id="close" class="fa fa-times-circle"></i>
			<h1><%= title %></h1>
		</header>
		<div id="content">
			<%= body %>
		</div>
	"""
	events:
		'click #close': 'handleClickClose'
		'click #ok': 'handleClickOk'
		'click #cancel': 'handleClickCancel'

	initialize: ( { @id, @model } ) ->

	handleClickClose: ->
		window.close()

	handleClickOk: -> alert('ok')
	handleClickCancel: -> alert('cancel')


class DialogController
	constructor: ->
		$body = $ 'body'
		@dialogRegion = new Marionette.Region( el: $body[0] )

	dialogIdInstance: ->
		querystring.parse( window.location.search ).id

	show: ->
		dialogView = new DialogView( model: getKeyDialog )
		@dialogRegion.show( dialogView )

getKeyDialog = new Dialog
	title: "&Xi;thos"
	body: """
		<p>A ÐApp is requesting a new private key.</p>
		<div class="buttons">
			<button id="cancel">Cancel</button>
			<button id="ok">OK</button>
		</div>
	"""

$ ->
	console.log 'Ethos dialog view init.'
	dialogController = new DialogController()
	dialogController.show()