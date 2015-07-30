module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('./package.json'),
    nodewebkit: {
      options: {
        version: '0.12.2',
        build_dir: './dist',
        // specifiy what to build
        mac: true,
        win: true,
        macIcns: 'app/images/logo.icns',
        // commented out as it fails on osx,
        // uncomment to build with icon on win
        // winIco: 'app/images/logo.ico',
        //linux32: true,
        //linux64: true
      },
      src: ['**/**', '!**/dist/**', '!**/eth/blockchain/**', '!**/eth/key*/**', '!**/eth/extra/**', '!**/eth/state/**', '!**/eth/node*/**', '!**/eth/geth.ipc', '!**/cache/**', '!**/node_modules/grunt*/**', '!**/node_modules/nw*/**', '!**/Gruntfile.js']
    },
  });

  grunt.loadNpmTasks('grunt-node-webkit-builder');
  grunt.registerTask('default', ['nodewebkit']);
};
