require 'supererror'
_                   = require 'lodash'
program             = require 'commander'

#
#
# Monkey-patch commander
#
#

# Allow us to display help(), but omit the wildcard (*) command.
program.Command::usageMinusWildcard = program.usageMinusWildcard = ()->
  program.commands = _.reject program.commands,
    _name: '*'
  program.help()


# Force commander to display version information.
program.Command::versionInformation = program.versionInformation = ()->
  program.emit 'version'


module.exports = program
