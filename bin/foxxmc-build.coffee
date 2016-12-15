# require 'supererror'
_                   = require 'lodash'
nodepath            = require 'path'
{spawn, exec}       = require 'child_process'
_package            = require '../package.json'

###
   `foxx watch`

   Start the FoxxMC app in the current directory.
###

module.exports = ()->
  scope =
    rootPath: process.cwd()
    foxxmcRoot: nodepath.resolve __dirname, '..'
    env: null
    server: null
    modules: {}
    foxxmcPackageJSON: _package

  # Pass the original CLI arguments down to the generator
  # (but first, remove commander's extra argument)
  cliArguments = _.initial arguments

  start = (command)->
    t_start = Date.now()
    npm = spawn 'npm', ['install'], cwd: scope.rootPath
    npm.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    npm.stdout.on 'data', (data) ->
      console.log data.toString()
    npm.on 'exit', (code) ->
      console.log 'npm install was closed with code ' + code  + ' at ' + (Date.now() - t_start) + ' ms\n'

      gulp = spawn 'gulp', [command], cwd: scope.rootPath
      gulp.stderr.on 'data', (data) ->
        process.stderr.write data.toString()
      gulp.stdout.on 'data', (data) ->
        console.log data.toString()
      gulp.on 'exit', (code) ->
        console.log 'Gulp was closed with code ' + code + '\n'
        return

  start 'build'
