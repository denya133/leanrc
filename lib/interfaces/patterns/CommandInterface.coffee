

module.exports = (Module)->
  {
    NilT
    FuncG
    NotificationInterface
    NotifierInterface
  } = Module::

  class CommandInterface extends NotifierInterface
    @inheritProtected()
    @module Module

    @virtual execute: FuncG NotificationInterface, NilT


    @initialize()
