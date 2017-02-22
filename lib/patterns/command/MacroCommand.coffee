RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::MacroCommand extends RC::CoreObject
    @implements LeanRC::CommandInterface



  return LeanRC::MacroCommand.initialize()
