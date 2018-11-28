

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, MaybeG
    NotificationInterface
    Interface
  } = Module::

  class ObserverInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual setNotifyMethod: FuncG Function, NilT
    @virtual setNotifyContext: FuncG AnyT, NilT
    @virtual getNotifyMethod: FuncG [], MaybeG Function
    @virtual getNotifyContext: FuncG [], MaybeG AnyT
    @virtual compareNotifyContext: FuncG AnyT, Boolean
    @virtual notifyObserver: FuncG NotificationInterface, NilT


    @initialize()
