RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::NotifierInterface extends RC::Interface
    @public @virtual sendNotification: Function,
      args: [String, RC::Constants.ANY, String]
      return: RC::Constants.NILL
    @public @virtual initializeNotifier: Function,
      args: [String]
      return: RC::Constants.NILL


  return LeanRC::NotifierInterface.initialize()
