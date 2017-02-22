RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Notifier extends RC::CoreObject
    @implements LeanRC::NotifierInterface



  return LeanRC::Notifier.initialize()
