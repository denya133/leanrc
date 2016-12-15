#!/usr/bin/env coffee

require 'supererror'
_                   = require 'lodash'
program             = require './_commander'
_package            = require '../package.json'
NOOP                = ()->

program
  .version _package.version, '-v, --version'

#
# Normalize version argument, i.e.
#
# $ foxx -v
# $ foxx -V
# $ foxx --version
# $ foxx version
#

# make `-v` option case-insensitive
process.argv = _.map process.argv, (arg)->
  return if (arg is '-V') then '-v' else arg

# $ foxx version (--version synonym)
program
  .command 'version'
  .description ''
  .action program.versionInformation

program.usage '[command]'

# $ foxx watch
start_cmd = program.command 'watch'
start_cmd.unknownOption = NOOP
start_cmd.description ''
start_cmd.alias 'w'
start_cmd.action require './foxxmc-watch'

# $ foxx build
start_cmd = program.command 'build'
start_cmd.unknownOption = NOOP
start_cmd.description ''
start_cmd.alias 'b'
start_cmd.action require './foxxmc-build'

# $ foxx generate <module>
generate_cmd = program.command 'generate'
generate_cmd.unknownOption = NOOP
generate_cmd.description ''
generate_cmd.usage '[something]'
generate_cmd.alias 'g'
generate_cmd.action require './foxxmc-generate'

# $ foxx init <app_name>
new_cmd = program.command 'init [app_name]'
generate_cmd.usage '[app_name]'
new_cmd.unknownOption = NOOP
new_cmd.action require './foxxmc-new'

#
# Normalize help argument, i.e.
#
# $ foxx --help
# $ foxx help
# $ foxx
# $ foxx <unrecognized_cmd>
#

# $ foxx help (--help synonym)
help_cmd = program.command 'help'
help_cmd.description ''
help_cmd.action program.usageMinusWildcard

# $ foxx <unrecognized_cmd>
# Mask the '*' in `help`.
program
  .command '*'
  .action program.usageMinusWildcard

# Don't balk at unknown options
program.unknownOption = NOOP

# $ foxx
#
program.parse process.argv
NO_COMMAND_SPECIFIED = program.args.length is 0
if NO_COMMAND_SPECIFIED
  program.usageMinusWildcard()
