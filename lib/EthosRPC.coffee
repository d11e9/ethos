rpc = require('node-json-rpc')

class EthosRPC
  constructor: ({port, host, path}) ->
    @server = new rpc.Server
      port: port
      host: host
      path: path
      strict: false

    @server.addMethod 'logInfo', (para, callback) ->
      winston.info( para );
      callback( null, 'ok' );

    @server.addMethod 'logWarn', (para, callback) ->
      winston.warn( para );
      callback( null, 'ok' );

    @server.addMethod 'logError', (para, callback) ->
      winston.error( para );
      callback( null, 'ok' );

    @server.addMethod 'getKeys', (para, callback) ->
      winston.info( 'RPC getKeys' )
      error = { code: -32602, message: "Invalid params" }
      callback(error, result)

  start: (callback) ->
    @server.start( callback )

module.exports = EthosRPC