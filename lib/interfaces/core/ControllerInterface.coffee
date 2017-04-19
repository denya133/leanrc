RC = require 'RC'
{NILL} = RC::


module.exports = (LeanRC)->
  class LeanRC::ControllerInterface extends RC::Interface
    @inheritProtected()
    @Module: LeanRC

    @public @virtual executeCommand: Function,
      args: [LeanRC::NotificationInterface]
      return: NILL
    @public @virtual registerCommand: Function,
      args: [String, RC::Class]
      return: NILL
    @public @virtual hasCommand: Function,
      args: [String]
      return: Boolean
    @public @virtual removeCommand: Function,
      args: [String]
      return: NILL


  return LeanRC::ControllerInterface.initialize()
