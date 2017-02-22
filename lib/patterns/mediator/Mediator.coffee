RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Mediator extends RC::CoreObject
    @implements LeanRC::MediatorInterface



  return LeanRC::Mediator.initialize()
