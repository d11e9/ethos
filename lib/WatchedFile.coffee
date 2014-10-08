browserify = require 'browserify'
watchify = require 'watchify'
_ = require( 'underscore' )
path = require 'path'
fs = require 'fs'


class WatchedFile
  constructor: ({input, output, transform, args, winston}) ->

    args = _.extend( watchify.args, args || {} )
    @winston = winston
    @inputPath = path.join( __dirname, input )
    @outputPath = path.join( __dirname, output )
    @outputFile = @outputPath.split( '\\' )[-1..]
    @inputFile = @inputPath.split( '\\' )[-1..]

    bundle = browserify( @inputPath, args )
    bundle.transform( transform ) if transform

    @watched = watchify( bundle )
    @watched.on( 'update', @handleUpdate )
    @watched.bundle( @handleBundle )

  handleBundle: (err, src) =>
    if err
      @winston.error( err )
    else
      @winston.info( "Updating (#{ @outputFile }) on disk due to update in input file (#{ @inputFile })." )
      fs.writeFile @outputPath, src, (err) =>
        if err
          @winston.error( err )
        else
          @winston.info( "Success (#{ @outputFile }) written to disk." )

  handleUpdate: =>
    @watched.bundle( @handleBundle )

module.exports = WatchedFile