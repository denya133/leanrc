RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::ViewInterface extends RC::Interface
    @Module: LeanRC

    @public @virtual registerObserver: Function,
      args: [String, LeanRC::ObserverInterface]
      return: RC::Constants.NILL
    @public @virtual removeObserver: Function,
      args: [String, RC::Constants.ANY]
      return: RC::Constants.NILL
    @public @virtual notifyObservers: Function,
      args: [LeanRC::NotificationInterface]
      return: RC::Constants.NILL
    @public @virtual registerMediator: Function,
      args: [LeanRC::MediatorInterface]
      return: RC::Constants.NILL
    @public @virtual retrieveMediator: Function,
      args: [String]
      return: LeanRC::MediatorInterface
    @public @virtual removeMediator: Function,
      args: [String]
      return: LeanRC::MediatorInterface
    @public @virtual hasMediator: Function,
      args: [String]
      return: Boolean


  return LeanRC::ViewInterface.initialize()
