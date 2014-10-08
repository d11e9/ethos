$ = jquery = require 'jquery'
_ = require 'underscore'

Backbone = require 'backbone'
Backbone.$ = $
Marionette = require 'backbone.marionette'
querystring = require 'querystring'


class Dialog extends Backbone.Model
	defaults:
		title: 'Welcome Default'
		body: 'Default Welcome to Ethos an Ethereum Browser.'

class DialogView extends Marionette.ItemView
	template: _.template """
		<header>
			<i id="close" class="fa fa-times-circle"></i>
			<h1><%= title %></h1>
		</header>
		<div id="content">
			<p><%= body %></p>
		</div>
	"""
	events:
		'click #close': 'handleClickClose'

	initialize: ( { @id, @model } ) ->

	handleClickClose: ->
		window.close()


class DialogController
	constructor: ->
		$body = $ 'body'
		@dialogRegion = new Marionette.Region( el: $body[0] )

	dialogIdInstance: ->
		querystring.parse( window.location.search ).id

	show: ->
		dialogView = new DialogView( id: @dialogIdInstance(), model: new Dialog() )
		@dialogRegion.show( dialogView )


$ ->
	console.log 'Ethos dialog view init.'
	dialogController = new DialogController()
	dialogController.show()