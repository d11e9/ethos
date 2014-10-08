
Ethereum = require('./ethereumjs-lib')
 

class EthosRPC
  constructor: ({@dappManager, @winston }) ->

  handleRPC: (req, res, next) ->
    methods = @methods()
    for method in Object.keys( methods )
      res.rpc method, methods[ method ]

  methods: =>
    ping: (params, respond) =>
      respond( result: 'pong' )

    dapps: (params, respond) =>
      respond( result: @dappManager.dapps )

module.exports = EthosRPC

