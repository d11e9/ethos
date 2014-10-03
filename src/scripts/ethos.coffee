
$ = jquery = require 'jquery'
Backbone = require 'backbone'
Backbone.$ = $
Marionette = require 'backbone.marionette'

jquery ->

	$body = $ 'body'
	$body.addClass 'loaded'

	if window.location.hash is '#home'
		$body.addClass 'quick-load'
		window.location.hash = ''

	# Search Input
	$searchInput = $ '#search'
	$searchInput[0].onkeyup = ->
		console.log "search: #{ $searchInput.val() }"

	# Menu
	$menu = $ '#menu'
	$menu.click ->
		global.showGlobalDev()


	# DApps Collection
	class DAppView extends Marionette.ItemView
		template: "<dapps>asdasd</dapps>"

	ethos.dapps (err, dapps) ->
		DAppRegion = new Marionette.Region( el: $('#dapps')[0] )

		dappCollectionView = new Marionette.CollectionView
			collection: new Backbone.Collection( dapps )
			childView: DAppView
		
		DAppRegion.show( dappCollectionView )