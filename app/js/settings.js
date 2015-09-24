var path = require('path')
var execPath = function (package) {
	if (process.platform !== 'darwin' && process.execPath.indexOf('node_modules') === -1 )
		return path.join( process.execPath, '../', package );
	else return package;
}

require( execPath( 'coffee-script/register') )
require('./src/settings.coffee')( require('nw.gui') )