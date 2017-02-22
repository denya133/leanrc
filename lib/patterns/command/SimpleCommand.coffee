RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::SimpleCommand extends RC::CoreObject
    @implements LeanRC::CommandInterface



  return LeanRC::SimpleCommand.initialize()
