RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Controller extends RC::CoreObject
    @implements LeanRC::ControllerInterface


  return LeanRC::Controller.initialize()
