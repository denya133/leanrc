RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::ObserverInterface extends RC::Interface
    @public @virtual setNotifyMethod: Function,
      args: [Function]
      return: RC::Constants.NILL
    @public @virtual setNotifyContext: Function,
      args: [RC::Constants.ANY]
      return: RC::Constants.NILL
    @public @virtual getNotifyMethod: Function,
      args: []
      return: Function
    @public @virtual getNotifyContext: Function,
      args: []
      return: RC::Constants.ANY
    @public @virtual compareNotifyContext: Function,
      args: [RC::Constants.ANY]
      return: Boolean
    @public @virtual notifyObserver: Function,
      args: [LeanRC::NotificationInterface]
      return: RC::Constants.NILL



  return LeanRC::ObserverInterface.initialize()
