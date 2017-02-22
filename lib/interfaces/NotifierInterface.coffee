RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::NotifierInterface extends RC::Interface
    @public sendNotification: Function,
      args: [String, RC::Constants.ANY, String]
      return: RC::Constants.NILL
    @public initializeNotifier: Function,
      args: [String]
      return: RC::Constants.NILL


  return LeanRC::NotifierInterface.initialize()
