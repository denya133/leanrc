# including plugins
gulp = require 'gulp'
runSequence       = require 'run-sequence'

# task 'watch'
gulp.task 'watch', (cb)->
  runSequence ['remove_dist', 'remove_public']
  , 'compile_assets', 'generate_indexes', 'compile_coffee'
  , 'copy_javascript', 'symlink_node_modules', ()->
    gulp.watch ['./api/**/*.coffee', './api/**/*.js'], ['compile_coffee', 'copy_javascript']
    .on 'end', cb
    # gulp.watch ['./api/*.coffee'], ['compile_coffee']
    # gulp.watch ['./api/*.js'], ['copy_javascript']
