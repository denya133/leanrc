require 'supererror'
_                   = require 'lodash'
nodepath            = require 'path'
util                = require 'util'
reportback          = require('reportback')()
generator           = require './_generator'
_package            = require '../package.json'

###
   `foxx generate`

   Generate one or more file(s) in our working directory.
   This runs an appropriate generator.
###

module.exports = ()->
  scope =
    rootPath: process.cwd()
    foxxmcRoot: nodepath.resolve __dirname, '..'
    modules: {}
    foxxmcPackageJSON: _package

  # Pass the original CLI arguments down to the generator
  # (but first, remove commander's extra argument)
  # (also peel off the `generatorType` arg)
  cliArguments = _.initial arguments
  scope.generatorType = cliArguments.shift()
  scope.args = cliArguments


  # Create a new reportback
  cb = reportback.extend()

  # Show usage if no generator type is defined
  unless scope.generatorType
    return cb.log.error 'Usage: sails generate [something]'


  # Set the "invalid" exit to forward to "error"
  cb.error = (msg)->
    log = @log ? cb.log
    log.error msg
    process.exit 1


  cb.invalid = 'error'

  cb.success = ()->

    # Infer the `outputPath` if necessary/possible.
    if not scope.outputPath and scope.filename and scope.destDir
      scope.outputPath = scope.destDir + scope.filename


    # Humanize the output path
    if scope.outputPath
      humanizedPath = ' at ' + scope.outputPath
    else if scope.destDir
      humanizedPath = ' in ' + scope.destDir
    else
      humanizedPath = ''

    # Humanize the module identity
    if scope.id
      humanizedId = util.format ' ("%s")', scope.id
    else
      humanizedId = ''

    if scope.generatorType isnt 'new'
      cb.log.info util.format(
        'Created a new %s%s%s!'
        scope.generatorType
        humanizedId
        humanizedPath
      )

  generator scope, cb
