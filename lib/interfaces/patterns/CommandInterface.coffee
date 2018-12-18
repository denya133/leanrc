

module.exports = (Module)->
  {
    FuncG
    NotificationInterface
    NotifierInterface
  } = Module::

  class CommandInterface extends NotifierInterface
    @inheritProtected()
    @module Module

    @virtual execute: FuncG NotificationInterface


    @initialize()
