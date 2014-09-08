

express = require( 'express' )
http = require( 'http' )
request = require( 'request' )
jade = require( 'jade' )
path = require( 'path' )
winston = require( 'winston' )
_ = require( 'underscore' )

EthosRPC = require( './EthosRPC.coffee')
DAppManager = require( './DAppManager.coffee' )

PORT = 8080
app = express()
app.set( 'views', __dirname + '/../views' )
app.set( 'view engine', 'jade' )

server = http.createServer( app )
server.listen( PORT )

winston.add( winston.transports.File, { 
  filename: 'ethos.log',
  handleExceptions: true
})

process.on 'uncaughtException', (err) -> 
  console.log( err )
  winston.error( err )

winston.info( "Ethos server started at http://localhost:#{ PORT }" )

rpcServer = new EthosRPC
  port: 7001
  host: 'eth'
  path: '/'

rpcServer.start (err) ->
  throw err if err
  winston.info('Ethos RPC Server running on port 7001')


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

manager = new DAppManager( rootDir: path.join( __dirname, '../dapps' ) )
winston.info 'DApps: ', Object.keys manager.dapps

app.use( manager.middleware( app, winston ) )

app.get '/', (req,res) -> 
  winston.info "Redirecting to Ethos DApp."
  res.redirect '/ethos'

app.get '/favicon.ico', (req,res) -> res.sendFile( './assets/favicon.ico', root: './static' )

app.get '/ethos/', (req, res) ->
  app.currentDApp = 'ethos'
  res.render( 'index', { dapps: manager.dapps } )

app.get '/ethos/static/*', (req, res) ->
  res.sendFile( req.url.replace('/ethos/static/', '' )  , {root: './static'})
