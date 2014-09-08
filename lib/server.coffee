

express = require( 'express' )
http = require( 'http' )
request = require( 'request' )
jade = require( 'jade' )
path = require( 'path' )
winston = require( 'winston' )
_ = require( 'underscore' )

console.log( '<<<<<<<<', __dirname )
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

app.currentDApp = 'ethos'

manager = new DAppManager
  rootDir: path.join( __dirname, '../dapps' )

winston.info 'DApps: ', Object.keys manager.dapps

process.on 'uncaughtException', (err) -> 
  console.log( err )
  winston.error( err )

isAsset = (req) -> req.url.match( /\./ )?

app.use (req,res,next) ->
  dappName = app.currentDApp;
  winston.info 'URL: ' + req.url 
  winston.info 'is asset: ' + isAsset( req )
  # Assets will have extentions and no slashes
  if isAsset( req ) and dappName isnt 'ethos'
    winston.info( 'Serve dapp asset:' )
    res.sendFile( req.url, {root: "./dapps/#{ dappName }"} );
  else
    next()

app.get '/', (req,res) -> 
  winston.info "Redirecting to Ethos DApp."
  res.redirect '/ethos'

app.get '/ethos/', (req, res) ->
  app.currentDApp = 'ethos'
  res.render( 'index', { dapps: manager.dapps } )

app.get '/ethos/static/*', (req, res) ->
  res.sendFile( req.url.replace('/ethos/static/', '' )  , {root: './static'});


app.get /^\/(.*)/i, (req,res) ->
  if isAsset( req )
    winston.info( 'DApp asset.' )
  else
    url = req.params[0]
    dappName = url.split('/')[0]
    dapp = manager.dapps[ dappName ]
    app.currentDApp = dappName

    unless dapp
      res.status( 404 )
        .send( "404: DApp (#{ dappName }) Not Found." )
    else
      dapp.root = "#{ dappName }/#{ dapp.html }"
      res.sendFile( dapp.root, { root: './dapps' } )

# URL Resolution
# require( './URLProxy')( app, server )

