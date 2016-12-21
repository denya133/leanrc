require 'supererror'
gulp              = require 'gulp'
symlink           = require 'gulp-symlink'
{ join }          = require 'path'
{ node_modules }  = require '../../manifest'

ROOT = join __dirname, '../..'


gulp.task 'symlink_node_modules', ()->
  node_modules.map (name)->
    gulp.src "node_modules/#{name}", cwd: join ROOT
      .pipe symlink "./dist/node_modules/#{name}"
