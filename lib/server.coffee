
require('coffee-script/register')

_ = require( 'underscore' )
fs = require( 'fs' )
express = require( 'express' )
http = require( 'http' )
request = require( 'request' )
jade = require( 'jade' )
path = require( 'path' )
winston = require( 'winston' )

browserify = require 'browserify'
watchify = require 'watchify'
coffeeify = require 'coffeeify'

exec = require( 'child_process' ).exec

EthosRPC = require( './EthosRPC.coffee')(winston)
DAppManager = require( './DAppManager.coffee' )

PORT = 8080
RPC_PORT = 7001
ETH_PORT = 7002

app = express()
app.set( 'views', __dirname + '/../app/views' )
app.set( 'view engine', 'jade' )

app.listen( PORT )

winston.add( winston.transports.File, { 
  filename: './logs/ethos.log',
  handleExceptions: true
})

process.on 'uncaughtException', (err) -> 
  console.log( err )
  winston.error( err )

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

# RPC
rpcServer = new EthosRPC
  port: RPC_PORT
  host: 'eth'
  path: '/'
  dappManager: dappManager

rpcServer.start (err) ->
  throw err if err
  winston.info( "Ethos RPC Server running on port #{ RPC_PORT }")

# Intercepts all requests and checks if it needs to load a ÐApp.
# If a ÐApp is loaded then assets are served from that DApps root folder.
app.use( dappManager.middleware( app, winston ) )

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
  res.render( 'dialog' )

# Serve other ethos assets
app.get '/ethos/app/*', (req, res) ->
  res.sendFile( req.url.replace('/ethos/app/', '' ), {root: './app'} )


class WatchedFile
  constructor: ({input, output, transform, args}) ->

    args = _.extend( watchify.args, args || {} )

    @inputPath = path.join( __dirname, input )
    @outputPath = path.join( __dirname, output )
    @outputFile = @outputPath.split( '\\' )[-1..]
    @inputFile = @inputPath.split( '\\' )[-1..]

    bundle = browserify( @inputPath, args )
    bundle.transform( transform ) if transform

    @watched = watchify( bundle )
    @watched.on( 'update', @handleUpdate )
    @watched.bundle( @handleBundle )

  handleBundle: (err, src) =>
    if err
      winston.error( err )
    else
      winston.info( "Updating (#{ @outputFile }) on disk due to update in input file (#{ @inputFile })." )
      fs.writeFile @outputPath, src, (err) =>
        if err
          winston.error( err )
        else
          winston.info( "Success (#{ @outputFile }) written to disk." )

  handleUpdate: =>
    @watched.bundle( @handleBundle )


new WatchedFile
  input: '../src/scripts/inject.coffee'
  output: '../app/scripts/inject.bundle.js'
  transform: coffeeify
  args:
    test: true

new WatchedFile
  input: '../src/scripts/ethos.coffee'
  output: '../app/scripts/ethos.bundle.js'
  transform: coffeeify

new WatchedFile
  input: '../src/scripts/bootstrap-client.coffee'
  output: '../app/scripts/bootstrap-client.bundle.js'
  transform: coffeeify
  args:
    ignoreMissing: true


# 404
app.get '*', (req,res) ->
  res.render( '404', { url: req.url } )
