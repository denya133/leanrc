

module.exports = (Module)->
  {
    FuncG, SubsetG
    Interface
    NotificationInterface
    CommandInterface
  } = Module::

  class ControllerInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual executeCommand: FuncG NotificationInterface
    @virtual registerCommand: FuncG [String, SubsetG CommandInterface]
    @virtual hasCommand: FuncG String, Boolean
    @virtual removeCommand: FuncG String


    @initialize()
