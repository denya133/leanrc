

module.exports = (Module)->
  {ANY, NILL} = Module::

  class ObserverInterface extends Module::Interface
    @inheritProtected()
    @module Module

    @public @virtual setNotifyMethod: Function,
      args: [Function]
      return: NILL
    @public @virtual setNotifyContext: Function,
      args: [ANY]
      return: NILL
    @public @virtual getNotifyMethod: Function,
      args: []
      return: Function
    @public @virtual getNotifyContext: Function,
      args: []
      return: ANY
    @public @virtual compareNotifyContext: Function,
      args: [ANY]
      return: Boolean
    @public @virtual notifyObserver: Function,
      args: [Module::NotificationInterface]
      return: NILL



  ObserverInterface.initialize()
