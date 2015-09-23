express = require 'express'
bodyParser = require 'body-parser'
multer = require 'multer'
path = require 'path'
_ = require 'underscore'


module.exports = ({config}) ->
	server = express()
	server.listen 8080, ->
		console.log "Ethos DApp server running."

	server.get '/dapp/:dappName', (req,res,next) ->
		dapp = _.findWhere( config.get('localDApps'), {name: req.params.dappName} )
		if dapp
			res.sendFile( dapp.path )
		else 
			next()

	server.get '*', (req, res) ->
		dappName = req.headers.referer.replace('http://localhost:8080/dapp/', '')
		dapp = _.findWhere( config.get('localDApps'), {name: dappName} )

		if dapp
			res.sendFile( path.join( dapp.path, '..', req.path.replace('/dapp/', '') ) )
		else
			console.log( dappName, dapp, req )
			res.status(404).end()
		
