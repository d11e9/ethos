
$ = jquery = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'
Backbone.$ = $
Marionette = require 'backbone.marionette'



{ EthosAppView, SearchView, DAppView, DAppCollectionView, MenuView } = require './views/index.coffee'
{ DApp, DAppCollection } = require './models/index.coffee'

jquery ->

	$body = $ 'body'
	
	if window.location.hash is '#home'
		$body.addClass 'quick-load'
		window.location.hash = ''

	# Ethos
	AppRegion = new Marionette.Region( el: $('#ethos')[0] )
	ethosAppView = new EthosAppView()
	AppRegion.show( ethosAppView )

	# Menu
	ethosAppView.menuRegion.show( new MenuView() )

	# DApps
	ethos?.dapps? (err, dapps) ->
		dapps = _.values( dapps )
		dappCollection = new DAppCollection( dapps )
		dappCollectionView = new DAppCollectionView( collection: dappCollection )
		
		ethosAppView.dappsRegion.show( dappCollectionView )
		ethosAppView.searchRegion.show( new SearchView( collection: dappCollection ) )
		
	$body.addClass 'loaded'