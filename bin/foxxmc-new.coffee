require 'supererror'
_                   = require 'lodash'
nodepath            = require 'path'
generator           = require './_generator'
_package            = require '../package.json'

###
   `foxx init`

   Generate a new FoxxMC app in the current directory.
###

module.exports = (..., command)->
  scope =
    rootPath: process.cwd()
    foxxmcRoot: nodepath.resolve __dirname, '..'
    boilerplate: null
    modules: {}
    foxxmcPackageJSON: _package

  # Pass the original CLI arguments down to the generator
  # (but first, remove commander's extra argument)
  cliArguments = Array::slice.call arguments

  cliArguments.pop()
  scope.app_name = cliArguments[0]

  scope.generatorType = 'init'

  generator scope,
    success: ()->
