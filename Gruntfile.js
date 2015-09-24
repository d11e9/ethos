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
      src: ['**/**', '!**/dist/**', '!**/cache/**', '!**/installer/**', '!**/node_modules/grunt*/**', '!**/node_modules/nw*/**', '!**/Gruntfile.js']
    },
  });

  grunt.loadNpmTasks('grunt-nw-builder');
  grunt.registerTask('default', ['nwjs']);
};
