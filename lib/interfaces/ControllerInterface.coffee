RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::ControllerInterface extends RC::Interface
    @public executeCommand: Function,
      args: [LeanRC::NotificationInterface]
      return: RC::Constants.NILL
    @public registerCommand: Function,
      args: [String, RC::Class]
      return: RC::Constants.NILL
    @public hasCommand: Function,
      args: [String]
      return: Boolean
    @public removeCommand: Function,
      args: [String]
      return: RC::Constants.NILL


  return LeanRC::ControllerInterface.initialize()
