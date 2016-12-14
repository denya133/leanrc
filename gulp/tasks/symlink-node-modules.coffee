require 'supererror'
gulp              = require 'gulp'
symlink           = require 'gulp-symlink'
# fs                = require 'fs-extra'
# gcopy             = require 'gulp-copy'
{ join }          = require 'path'

ROOT = join __dirname, '../..'


gulp.task 'symlink_node_modules', ()->
  gulp.src 'node_modules', cwd: join ROOT
    .pipe symlink './dist/node_modules'
