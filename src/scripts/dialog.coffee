$ = jquery = require 'jquery'
_ = require 'underscore'

Backbone = require 'backbone'
Backbone.$ = $
Marionette = require 'backbone.marionette'
querystring = require 'querystring'


class Dialog extends Backbone.Model


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

	handleClickOk: ->
		global.vent.emit 'dialog:ok'
		window.close()

	handleClickCancel: ->
		global.vent.emit 'dialog:cancel'
		window.close()


class DialogController
	constructor: ->
		$body = $ 'body'
		@dialogRegion = new Marionette.Region( el: $body[0] )

	show: ->
		model = switch querystring.parse( window.location.search ).page
			when 'key' then @getKeyDialog()
			when 'settings' then @settingsDialog()
			else @settingsDialog()
		dialogView = new DialogView( { model } )
		@dialogRegion.show( dialogView )

	getKeyDialog: -> new Dialog
		title: "&Xi;thos"
		body: """
			<p>A ÐApp is requesting a new private key.</p>
			<div class="buttons">
				<button id="cancel">Cancel</button>
				<button id="ok">OK</button>
			</div>
		"""

	welcomeDialog: -> new Dialog
		title: 'Welcome Default'
		body: '<p>Default Welcome to Ethos an Ethereum Browser.</p>'

	settingsDialog: -> new Dialog
		title: "&Xi;thos Settings"
		body: """
			<form action="">
				<div><label for="">Setting: </label><input type="text"></div>
				<div><label for="">Setting: </label><input type="text"></div>
				<div><label for="">Setting: </label><input type="text"></div>
				<div><label for="">Setting: </label><input type="text"></div>
				<div><label for="">Setting: </label><input type="text"></div>
				<div><label for="">Setting: </label><input type="text"></div>
				<div class="buttons">
					<button id="cancel">Cancel</button>
					<button id="ok">OK</button>
				</div>
			</form>
		"""

$ ->
	global.windows.dialog.focus()
	global.winston.info 'Ethos Dialog view init.'
	dialogController = new DialogController()
	dialogController.show()