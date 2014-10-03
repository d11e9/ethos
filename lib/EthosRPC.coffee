rpc = require('node-json-rpc')
Ethereum = require('./ethereumjs-lib')

module.exports = (winston) ->

  class EthosRPC
    constructor: ({port, host, path, dappManager }) ->
      @dappManager = dappManager
      @server = new rpc.Server
        port: port
        host: host
        path: path
        strict: false

      @server.addMethod 'ping', (para,callback) ->
        winston.info( 'RPC Ping')
        callback( null, 'pong')

      @server.addMethod 'logInfo', (para, callback) ->
        winston.info( para )
        callback( null, 'ok' )

      @server.addMethod 'logWarn', (para, callback) ->
        winston.warn( para )
        callback( null, 'ok' )

      @server.addMethod 'logError', (para, callback) ->
        winston.error( para )
        callback( null, 'ok' )

      @server.addMethod 'getKey', (para,callback) =>
        winston.info( @dappManager.currentDApp + " ÐApp requested KEY." )
        key = if @dappManager.currentDApp is 'ethos'
          "1Ex4mPl3Privkey"
        else
          @dappManager.dapps[ @dappManager.currentDApp ]?.key
        
        if key
          winston.info( "ÐApp #{ @dappManager.currentDApp } KEY is: " + key )
          callback( null, key )
        else
          winston.info( "ÐApp #{ @dappManager.currentDApp } has no key pair..." )
          callback( null, null )

      @server.addMethod 'dapps', (para, callback) =>
        winston.info( 'RPC dapps requested.' )
        callback( null, @dappManager.dapps )

      @server.addMethod 'getKeys', (para, callback) ->
        winston.info( 'RPC getKeys' )
        error = { code: -32602, message: "Invalid params" }
        callback(error, ['123132123','123123124'])

    start: (callback) ->
      @server.start( callback )

