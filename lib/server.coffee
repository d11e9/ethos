
require('coffee-script/register')

_ = require( 'underscore' )
fs = require 'fs'
express = require 'express'
http = require 'http'
request = require 'request'
jade = require 'jade'
path = require 'path'
winston = require 'winston'
jsonrpc = require( 'node-express-JSON-RPC2' )()
coffeeify = require 'coffeeify'

EthosRPC = require( './EthosRPC.coffee')
DAppManager = require( './DAppManager.coffee' )
WatchedFile = require( './WatchedFile.coffee' )

PORT = 8080
RPC_PORT = 7001
ETH_PORT = 7002

winston.add winston.transports.File, 
  filename: './logs/ethos.log'
  handleExceptions: true

global.winston = winston

process.on 'uncaughtException', (err) -> 
  console.log( err )
  winston.info( "Ethos Node instance UncaughtException." )
  winston.error( "Ethos Node instance UncaughtException.", err )

winston.info( "Ethos server started at http://localhost:#{ PORT }" )

# FIXME: Techinal Debt.
# Temporary solution to node-ethereum failing when run in a node-webkit context.
# Run node-ethereum via the shell, this makes node.js a runtime dependency.

#exec 'coffee ./lib/ethereum-server.coffee -n ' + ETH_PORT, (error) ->
#  winston.error( "Error running node-ethereum process.", error ) if error

# ÐApp Manager
dappManager = new DAppManager
  rootDir: path.join( __dirname, '../dapps' )
  winston: winston

winston.info "Ethos ÐApps: #{ Object.keys( dappManager.dapps ).join(', ') }"


app = express()
app.set( 'views', __dirname + '/../app/views' )
app.set( 'view engine', 'jade' )
app.use( dappManager.middleware( app, winston ) )
app.use( jsonrpc )
app.listen( PORT )


# # RPC
rpcServer = new EthosRPC
  winston: winston
  dappManager: dappManager
  global: global

app.all '/ethos/api', (req, res, next) ->
  winston.info "Handling Ethos RPC request."
  rpcServer.handleRPC( req, res, next )


# Intercepts all requests and checks if it needs to load a ÐApp.
# If a ÐApp is loaded then assets are served from that DApps root folder.


# Ethos specific routes
# Redirect to ethos namespace
app.get '/', (req,res) -> 
  winston.info "Redirecting to Ethos ÐApp."
  res.redirect '/ethos'

# Render Ethos index view
app.get '/ethos/', (req, res) ->
  dappManager.currentDApp = 'ethos'
  winston.info "Serving Ethos."
  res.render( 'index', { dapps: dappManager.dapps } )

app.get '/ethos/dialog', (req, res) ->
  dappManager.currentDApp = 'ethos'
  winston.info "Serving Ethos dialog: #{ req.url }"
  res.render( 'dialog' )

# Serve other ethos assets
app.get '/ethos/app/*', (req, res) ->
  winston.info "Serving Ethos asset: #{ req.url }"
  res.sendFile( req.url.replace('/ethos/app/', '' ), {root: './app'} )



new WatchedFile
  input: '../src/scripts/inject.coffee'
  output: '../app/scripts/inject.bundle.js'
  winston: winston
  transform: coffeeify
  args:
    standalone: 'EthosInject'

new WatchedFile
  input: '../src/scripts/ethos.coffee'
  output: '../app/scripts/ethos.bundle.js'
  winston: winston
  transform: coffeeify
  args:
    standalone: 'Ethos'

new WatchedFile
  input: '../src/scripts/dialog.coffee'
  output: '../app/scripts/dialog.bundle.js'
  winston: winston
  transform: coffeeify
  args:
    standalone: 'Dialog'

new WatchedFile
  input: '../src/scripts/bootstrap-client.coffee'
  output: '../app/scripts/bootstrap-client.bundle.js'
  winston: winston
  transform: coffeeify
  args:
    ignoreMissing: true
    standalone: 'BootstrapClient'


# 404
app.get '*', (req,res) ->
  winston.info "Serving Ethos 404 page. url: #{ req.url }"
  res.render( '404', { url: req.url } )
