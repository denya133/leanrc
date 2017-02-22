RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Model extends RC::CoreObject
    @implements LeanRC::ModelInterface



  return LeanRC::Model.initialize()
