var path = require( 'path' )
var fs = require( 'fs' )
var util = require( 'util' )

var mkdir = function(dir) {
  // making directory without exception if exists
  try {
    fs.mkdirSync(dir, 0755);
  } catch(e) {
    if(e.code != "EEXIST") {
      throw e;
    }
  }
};

var copyDir = function(src, dest) {
  if (!fs.lstatSync(src).isDirectory() && !fs.lstatSync(src).isSymbolicLink()) {
    copy(src, dest);
  } else {
  mkdir(dest);
    var files = fs.readdirSync(src);
    for(var i = 0; i < files.length; i++) {
      var current = fs.lstatSync(path.join(src, files[i]));
      if(current.isDirectory()) {
        copyDir(path.join(src, files[i]), path.join(dest, files[i]));
      } else if(current.isSymbolicLink()) {
        var symlink = fs.readlinkSync(path.join(src, files[i]));
        fs.symlinkSync(symlink, path.join(dest, files[i]));
      } else {
        copy(path.join(src, files[i]), path.join(dest, files[i]));
      }
    }
  }
};

var copy = function(src, dest) {
  var oldFile = fs.createReadStream(src);
  var newFile = fs.createWriteStream(dest);
  //console.log( 'copying file: ', src, dest )
  oldFile.pipe( newFile )
}

module.exports = function(grunt) {
  grunt.initConfig({
    nwjs: {
      options: {
        version: '0.12.2',
        buildDir: './dist', // Where the build version of my NW.js app is saved
        credits: './app/Credits.html',
        macIcns: './app/images/logo.icns', // Path to the Mac icon file
        winIco: './app/images/logo.ico',
        platforms: ['win'] // These are the platforms that we want to build
      },
      src: [ 'package.json', 'app/**']
    },
    external: {
      src: [ './package.json', './eth', './node_modules', './bin', './ipfs']
    }
  });

  grunt.loadNpmTasks('grunt-nw-builder');

  grunt.registerTask('external', 'Copy external files to program folder', function() {
    var src = grunt.config('external.src');
    var dest = grunt.config('nwjs.options.buildDir');

    grunt.log.writeln("Copy EXTERNAL FILES: ", src, dest );
    var targets = grunt.file.expand({cwd: dest}, ["*/*"])
    for (var t in targets) {
      for (var f in src) {
        var a = path.join( src[f] )
        var b = path.join( dest, targets[t], src[f] )
        grunt.log.writeln( "copying ", a, " to ", b)
        copyDir( a, b )
      }
    }
  });

  grunt.registerTask('default', ['nwjs', 'external']);
};
