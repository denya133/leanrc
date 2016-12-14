# including plugins
gulp = require 'gulp'
runSequence       = require 'run-sequence'

# task 'watch'
gulp.task 'watch', (cb)->
  runSequence ['remove_dist', 'remove_public'], 'compile_assets', 'compile_coffee', 'copy_javascript', 'symlink_node_modules', ()->
    gulp.watch ['./src/**/*.coffee', './src/**/*.js'], ['compile_coffee', 'copy_javascript']
    .on 'end', cb
    # gulp.watch ['./src/*.coffee'], ['compile_coffee']
    # gulp.watch ['./src/*.js'], ['copy_javascript']
