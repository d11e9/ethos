http = require( 'http' )
nodeEthereum = require( './node-ethereum' )
winston = require( 'winston' )

winston.add( winston.transports.File, { 
  filename: 'ethos-ethereum.log',
  handleExceptions: true
})

# This server is designed to be run as a daemon 
# and will be passed the PORT by the calling process.

ARGS = process.argv
PORT = ARGS[3]

# Ethereum Network
# FIXME: Does not currently compile on windows
  
ethApp = new nodeEthereum()

ethApp.start ->
	winston.info( 'node-ethereum running...' )


winston.info "Loaded ethereum-node."
