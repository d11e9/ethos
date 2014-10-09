
Ethereum = require('./ethereumjs-lib')
 

class EthosRPC
  constructor: ({@dappManager, @winston, @global }) ->

  handleRPC: (req, res, next) ->
    methods = @methods()
    for method in Object.keys( methods )
      res.rpc method, methods[ method ]

  methods: =>
    ping: (params, respond) =>
      respond( result: 'pong' )

    dialog: (params, respond) =>
      @winston.info( "RPC Dialog request.", params )
      #@global.showDialog()
      respond( result: 'ok' )


    dapps: (params, respond) =>
      respond( result: @dappManager.dapps )

module.exports = EthosRPC

