RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Facade extends RC::CoreObject
    @implements LeanRC::FacadeInterface



  return LeanRC::Facade.initialize()
