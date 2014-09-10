
require('coffee-script/register')

express = require( 'express' )
http = require( 'http' )
request = require( 'request' )
jade = require( 'jade' )
path = require( 'path' )
winston = require( 'winston' )
_ = require( 'underscore' )
exec = require( 'child_process' ).exec

EthosRPC = require( './EthosRPC.coffee')(winston)
DAppManager = require( './DAppManager.coffee' )

PORT = 8080
RPC_PORT = 7001
ETH_PORT = 7002

app = express()
app.set( 'views', __dirname + '/../views' )
app.set( 'view engine', 'jade' )

app.listen( PORT )

winston.add( winston.transports.File, { 
  filename: 'ethos.log',
  handleExceptions: true
})

process.on 'uncaughtException', (err) -> 
  console.log( err )
  winston.error( err )

winston.info( "Ethos server started at http://localhost:#{ PORT }" )

# FIXME: Techinal Debt.
# Temprary solution to node-ethereum failing when run in a node-webkit context.
# Run node-ethereum via the shell, this makes node.js a runtime dependency.

exec 'coffee ./lib/ethereum-server.coffee -n ' + ETH_PORT, (error, stdout, stderr) ->
  if error?
    console.log('exec error: ' + error)
    console.log('stderr: ' + stderr);
  else
    console.log('Child process Node-v running.')
    console.log('stdout: ' + stdout)

# Ethereum Network
# FIXME: Does not currently compile on windows
# try

#   nodeEthereum = require( './node-ethereum' )
#   ethApp = new nodeEthereum()
  
#   ethApp.start ->
#     winston.info( 'node-ethereum running...' )

# catch err
#   winston.error "Error loading node-ethereum", err

# winston.info "Loaded ethereum-node."

# DApp Manager
dappManager = new DAppManager( rootDir: path.join( __dirname, '../dapps' ) )
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

# Intercepts all requests and checks if it needs to load a DApp.
# If a DApp is loaded then assets are served from that DApps root folder.
app.use( dappManager.middleware( app, winston ) )

# Ethos specific routes
# Redirect to ethos namespace
app.get '/', (req,res) -> 
  winston.info "Redirecting to Ethos DApp."
  res.redirect '/ethos'

# Serve favicon
app.get '/favicon.ico', (req,res) -> res.sendFile( './assets/favicon.ico', root: './static' )

# Render Ethos index view
app.get '/ethos/', (req, res) ->
  dappManager.currentDApp = 'ethos'
  res.render( 'index', { dapps: dappManager.dapps } )

# Serve other ethos assets
app.get '/ethos/static/*', (req, res) ->
  res.sendFile( req.url.replace('/ethos/static/', '' )  , {root: './static'})

# 404
app.get '*', (req,res) ->
  res.render( '404', { url: req.url } )