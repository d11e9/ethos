$ = jquery = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'
Backbone.$ = $
Marionette = require 'backbone.marionette'

views = {}

class views.EthosAppView extends Marionette.LayoutView
	template: _.template """
		<div class="search-region"></div>
		<div class="menu-region"></div>
		<div class="dapps-region"></div>
	"""
	regions:
		dappsRegion: '.dapps-region'
		searchRegion: '.search-region'
		menuRegion: '.menu-region'


class views.MenuView extends Marionette.ItemView
	id: 'menu'
	template: _.template """
		<a href="">
			<i class="fa fa-cogs"></i>
		</a>
		<div class="inner"></div>
	"""

	events:
		'click': 'handleClick'

	handleClick: ->
		global.showGlobalDev()


class views.SearchView extends Marionette.ItemView
	id: "search"
	type: 'search'
	tagName: 'input'
	template: _.template """
	"""

	events:
		'keyup': 'handleKeyup'

	initialize: ({ @collection }) ->

	handleKeyup: ->
		@collection.trigger 'filter', @$el.val()


class views.DAppView extends Marionette.ItemView
	tagName: 'li'
	template: _.template """
		<a href=":eth?dapp=<%- name %>">
			<i class='fa fa-<%= icon %>'></i>
			<span>
				<%= name %>
			</span>
		</a>
	"""


class views.DAppCollectionView extends Marionette.CollectionView
	id: "dapps"
	tagName: 'ul'
	childView: views.DAppView

module.exports = views