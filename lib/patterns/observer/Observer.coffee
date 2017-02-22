RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Observer extends RC::CoreObject
    @implements LeanRC::ObserverInterface



  return LeanRC::Observer.initialize()
