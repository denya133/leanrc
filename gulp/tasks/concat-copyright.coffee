# including plugins
gulp    = require 'gulp'
fse     = require 'fs-extra'
concat  = require 'gulp-concat'
header  = require 'gulp-header'
runSequence = require 'run-sequence'

# functions

# Get copyright using NodeJs file system
getCopyright = ()->
  fse.readFileSync './Copyright'


# task '_copy_dist'
gulp.task '_copy_dist', ()->
  gulp.src './_dist/**/*.js' # path to your files
  .pipe gulp.dest './dist'

# task '_remove_dist'
gulp.task '_remove_dist', (cb)->
  fse.remove './dist', cb

# task '_remove__dist'
gulp.task '_remove__dist', (cb)->
  fse.remove './_dist', cb

# task '_concat_copyright'
gulp.task '_concat_copyright', ()->
  gulp.src './dist/**/*.js' # path to your files
  # .pipe concat 'concat.js' # concat and name it "concat.js"
  .pipe header getCopyright()
  .pipe gulp.dest './_dist'

# task 'concat_copyright'
gulp.task 'concat_copyright', (cb)->
  runSequence '_remove__dist', '_concat_copyright', '_remove_dist', '_copy_dist', '_remove__dist', cb
