

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG
    NotificationInterface
    Interface
  } = Module::

  class ObserverInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual setNotifyMethod: FuncG Function, NilT
    @virtual setNotifyContext: FuncG AnyT, NilT
    @virtual getNotifyMethod: FuncG [], Function
    @virtual getNotifyContext: FuncG [], AnyT
    @virtual compareNotifyContext: FuncG AnyT, Boolean
    @virtual notifyObserver: FuncG NotificationInterface, NilT


    @initialize()
