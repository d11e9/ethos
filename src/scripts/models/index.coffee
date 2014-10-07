$ = jquery = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'
Backbone.$ = $
Marionette = require 'backbone.marionette'

models = {}

class models.DApp extends Backbone.Model


class models.DAppCollection extends Backbone.Collection
	model: models.DApp

class models.NameReg extends Backbone.Model
	initialize: ({@Config}) ->
		@set( 'Config', @Config )
		eth.stateAt @get( 'Config' ), "\0", (err, value) =>
			@set( 'NameReg', value ) unless err

	getAddr: (name) =>
		eth.stateAt @get( 'NameReg' ), eth.fromAscii( name ), (err, value) =>
			@set( name, value ) unless err

module.exports = models