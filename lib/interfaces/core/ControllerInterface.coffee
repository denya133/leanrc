

module.exports = (Module)->
  {
    NilT
    FuncG, SubsetG
    Interface
    NotificationInterface
    CommandInterface
  } = Module::

  class ControllerInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual executeCommand: FuncG NotificationInterface, NilT
    @virtual registerCommand: FuncG [String, SubsetG CommandInterface], NilT
    @virtual hasCommand: FuncG String, Boolean
    @virtual removeCommand: FuncG String, NilT


    @initialize()
