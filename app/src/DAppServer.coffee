express = require 'express'
bodyParser = require 'body-parser'
multer = require 'multer'
path = require 'path'
_ = require 'underscore'


module.exports = ({config}) ->
	server = express()
	server.listen 8080, ->
		console.log "Ethos DApp server running."

	server.get '/:dappName', (req,res) ->
		dapp = _.findWhere( config.get('localDApps'), {name: req.params.dappName} )
		res.sendFile( dapp.path )