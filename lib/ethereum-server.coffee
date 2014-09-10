http = require('http')

# This server is designed to be run as a daemon 
# and will be passed the PORT by the calling process.

ARGS = process.argv
PORT = ARGS[3]

server = http.createServer (req, res) ->
  res.writeHead( 200, {'Content-Type': 'text/plain'} )
  res.end( 'Hello World\n' + ARGS )

server.listen( parseInt( PORT ), '127.0.0.1' )
console.log( 'Server running at http://127.0.0.1:'+PORT+'/ with args ' + ARGS )