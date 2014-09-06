express = require( 'express' )
http = require( 'http' )
request = require( 'request' )
jade = require( 'jade' )
path = require( 'path' )
winston = require( 'winston' )

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



options = {
  #int port of rpc server, default 5080 for http or 5433 for https
  port: 7000,
  # string domain name or ip of rpc server, default '127.0.0.1'
  host: 'eth',
  # string with default path, default '/'
  path: '/',
  # boolean false to turn rpc checks off, default true
  strict: false
}
rpc = require('node-json-rpc')
serv = new rpc.Server(options)

serv.addMethod 'logInfo', (para, callback) ->
  winston.info( 'RPC Logging...' )
  winston.info( para );
  callback( null, 'ok' );

serv.addMethod 'logWarn', (para, callback) ->
  winston.info( 'RPC Logging...' )
  winston.warn( para );
  callback( null, 'ok' );

serv.addMethod 'logError', (para, callback) ->
  winston.info( 'RPC Logging...' )
  winston.error( para );
  callback( null, 'ok' );



serv.addMethod 'myMethod', (para, callback) ->
  # Add 2 or more parameters together
  winston.info( 'myMethod RPC' )
  if para.length == 2
    result = para[0] + para[1]
  else if para.length > 2
    result = 0
    para.forEach (v, i) ->
      result += v
  else
    error = { code: -32602, message: "Invalid params" }
  callback(error, result)


# Start the server
serv.start (error) ->
  # Did server start succeed ?
  if error 
    throw error
  else 
    winston.info('Ethos RPC Server running on port 7000 ...')

# Ethereum Network
# FIXME: Does not currently compile on windows

#nodeEthereum = require( './node-ethereum' )
# ethApp = new nodeEthereum()

#ethApp.start ->
#  app.get '/etherchain', (req,res) ->
#    res.render( 'etherchain', ethApp )


DAppManager = require( './DAppManager' )

manager = new DAppManager
  rootDir: path.join( __dirname, '../dapps' )

winston.info 'DApps: ', manager.dapps.map (app) -> app.name

app.get '/', (req, res) ->
  res.render( 'index', { dapps: manager.dapps } );

app.get '/static/*', (req, res) ->
  res.sendFile( req.url.replace('/static/', '' )  , {root: './static'});



# Torrents and Swarm
app.swarmClient = {}

# swarm = require( './swarm' )
# swarmClient = swarm( dataDir: './data/data', torrentDir: './data/torrents' )

# app.get '/swarm', (req,res) ->
#   res.render( 'swarm', torrents: swarmClient.torrents )



# URL Resolution
# require( './URLProxy')( app, server )

