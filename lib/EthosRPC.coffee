
Ethereum = require('./ethereumjs-lib')
 

class EthosRPC
  constructor: ({@dappManager, @winston, @global }) ->

  handleRPC: (req, res, next) ->
    methods = @methods()
    for method in Object.keys( methods )
      res.rpc method, methods[ method ]

  methods: =>
    ping: (params, respond) =>
      @winston.info( "RPC #ping request.", params )
      respond( result: 'pong' )

    dialog: (params, respond) =>
      @winston.info( "RPC #dialog request.", params )
      respond( result: 'ok' )
      # TODO: Fix headers already sent error
      #@global.showDialog()
    
    showDev: (params, respond) =>
      @winston.info( "RPC #showDev request.", params )
      global.showGlobalDev()

    logError: (params, respond) =>
      @winston.error( "RPC #logError request. Error: #{ params[0] }" )
      respond( result: 'ok' )

    dapps: (params, respond) =>
      @winston.info( "RPC #dapps request.", params )
      respond( result: @dappManager.dapps )

module.exports = EthosRPC

