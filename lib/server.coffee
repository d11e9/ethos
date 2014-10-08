
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

domain = require 'domain'

exec = require( 'child_process' ).exec

EthosRPC = require( './EthosRPC.coffee')
DAppManager = require( './DAppManager.coffee' )
WatchedFile = require( './WatchedFile.coffee' )

PORT = 8080
RPC_PORT = 7001
ETH_PORT = 7002

allowCrossDomain = (req, res, next) ->
  res.header('Access-Control-Allow-Origin', '127.0.0.1')
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
  res.header('Access-Control-Allow-Headers', 'Content-Type')
  next()



winston.add winston.transports.File, 
  filename: './logs/ethos.log'
  handleExceptions: true

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
winston.info 'DApps: ', Object.keys dappManager.dapps


app = express()
app.set( 'views', __dirname + '/../app/views' )
app.set( 'view engine', 'jade' )

app.use( dappManager.middleware( app, winston ) )

app.use( jsonrpc )


app.listen( PORT )
domain.create()


# # RPC
rpcServer = new EthosRPC
  winston: winston
  dappManager: dappManager

app.all '/ethos/api', (req, res, next) ->
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
  res.render( 'index', { dapps: dappManager.dapps } )

app.get '/ethos/dialog', (req, res) ->
  dappManager.currentDApp = 'ethos'
  res.render( 'dialog' )

# Serve other ethos assets
app.get '/ethos/app/*', (req, res) ->
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
  res.render( '404', { url: req.url } )
