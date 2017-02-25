RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::ViewInterface extends RC::Interface
    @Module: LeanRC

    @public registerObserver: Function,
      args: [String, LeanRC::ObserverInterface]
      return: RC::Constants.NILL
    @public removeObserver: Function,
      args: [String, RC::Constants.ANY]
      return: RC::Constants.NILL
    @public notifyObservers: Function,
      args: [LeanRC::NotificationInterface]
      return: RC::Constants.NILL
    @public registerMediator: Function,
      args: [LeanRC::MediatorInterface]
      return: RC::Constants.NILL
    @public retrieveMediator: Function,
      args: [String]
      return: LeanRC::MediatorInterface
    @public removeMediator: Function,
      args: [String]
      return: LeanRC::MediatorInterface
    @public hasMediator: Function,
      args: [String]
      return: Boolean



  return LeanRC::ViewInterface.initialize()
