RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::ObserverInterface extends RC::Interface
    @public setNotifyMethod: Function,
      args: [Function]
      return: RC::Constants.NILL
    @public setNotifyContext: Function,
      args: [Object]
      return: RC::Constants.NILL
    @public getNotifyMethod: Function,
      args: []
      return: Function
    @public getNotifyContext: Function,
      args: []
      return: Object
    @public compareNotifyContext: Function,
      args: [Object]
      return: Boolean
    @public notifyObserver: Function,
      args: [LeanRC::NotificationInterface]
      return: RC::Constants.NILL



  return LeanRC::ObserverInterface.initialize()
