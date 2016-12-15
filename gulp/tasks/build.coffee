# including plugins
gulp = require 'gulp'
runSequence       = require 'run-sequence'

# task 'build'
gulp.task 'build', (cb)->
  runSequence ['remove_dist', 'remove_public']
  , 'compile_assets', 'generate_indexes', 'compile_coffee'
  , 'copy_javascript', 'concat_copyright', 'create_package', cb
