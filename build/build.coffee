
console.log ('Building Ethos...')
console.log( 'Working dir: ', __dirname )

path = require( 'path' )

NwBuilder = require( 'node-webkit-builder' )
nw = new NwBuilder
  files: './**' # use the glob format
  platforms: ['win','osx']
  buildType: 'versioned'
  macZip: false
  macCredits: path.join( __dirname, './osx_credits.html' )
  macIcns: path.join( __dirname, './icons/ethereum-logo.icns' )
  winIco: path.join( __dirname, './icons/ethereum-logo.ico' )

# Log stuff you want
nw.on('log',  console.log);

# And supports callbacks
nw.build (err) ->
  if err
    console.log(err)
  else
    console.log( 'Success!')