

module.exports = (Module)->
  {NILL} = Module::

  class ControllerInterface extends Module::Interface
    @inheritProtected()
    @Module: Module

    @public @virtual executeCommand: Function,
      args: [Module::NotificationInterface]
      return: NILL
    @public @virtual registerCommand: Function,
      args: [String, Module::Class]
      return: NILL
    @public @virtual hasCommand: Function,
      args: [String]
      return: Boolean
    @public @virtual removeCommand: Function,
      args: [String]
      return: NILL


  ControllerInterface.initialize()
