


TorrentClient = require( 'node-torrent' )
NodeTorrent = require( 'nt' )
fs = require('fs');


module.exports = ({ torrentDir, dataDir }) ->

  torrents = fs.readdirSync( torrentDir )
  files = fs.readdirSync( dataDir )

  for filename in files
    dataPath = "#{ dataDir }/#{ filename }"
    console.log( "Creating torrent for data file: #{ dataPath }" )
    rs = NodeTorrent.make( 'http://myannounce.net/url', dataPath )

    torrentPath = "#{ torrentDir }/#{ filename }.torrent"
    console.log( "Creating torrent file: #{ torrentPath }" )
    rs.pipe( fs.createWriteStream( torrentPath ) )

  client = new TorrentClient
    logLevel: 'DEBUG'

  files = fs.readdirSync( torrentDir )
  for filename in files
    path = "#{ torrentDir }/#{ filename }"
    torrent = client.addTorrent( path )
    console.log( "Torrent file found: #{ path } status: #{ torrent.status }" )

  # when the torrent completes, move it's files to another area
  torrent.on 'complete', ->
    console.log('torrent complete!')
    torrent.files.forEach (file) ->
      # newPath = "/new/path/#{ file.path }"
      # fs.rename( file.path, newPath )
      # while still seeding need to make sure file.path points to the right place
      #file.path = newPath

  # Return client instance
  client




