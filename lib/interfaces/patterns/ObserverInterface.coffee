

module.exports = (Module)->
  {
    AnyT
    FuncG, MaybeG
    NotificationInterface
    Interface
  } = Module::

  class ObserverInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual setNotifyMethod: FuncG Function
    @virtual setNotifyContext: FuncG AnyT
    @virtual getNotifyMethod: FuncG [], MaybeG Function
    @virtual getNotifyContext: FuncG [], MaybeG AnyT
    @virtual compareNotifyContext: FuncG AnyT, Boolean
    @virtual notifyObserver: FuncG NotificationInterface


    @initialize()
