$ = jquery = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'
Backbone.$ = $
Marionette = require 'backbone.marionette'

models = {}

class models.DApp extends Backbone.Model


class models.DAppCollection extends Backbone.Collection
	model: models.DApp


module.exports = models