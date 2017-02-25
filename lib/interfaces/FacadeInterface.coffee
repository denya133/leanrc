RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::FacadeInterface extends RC::Interface
    @include LeanRC::NotifierInterface

    @Module: LeanRC

    @public registerCommand: Function,
      args: [String, RC::Class]
      return: RC::Constants.NILL
    @public removeCommand: Function,
      args: [String]
      return: RC::Constants.NILL
    @public hasCommand: Function,
      args: [String]
      return: Boolean

    @public registerProxy: Function,
      args: [LeanRC::ProxyInterface]
      return: RC::Constants.NILL
    @public retrieveProxy: Function,
      args: [String]
      return: LeanRC::ProxyInterface
    @public removeProxy: Function,
      args: [String]
      return: LeanRC::ProxyInterface
    @public hasProxy: Function,
      args: [String]
      return: Boolean

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

    @public notifyObservers: Function,
      args: [LeanRC::NotificationInterface]
      return: RC::Constants.NILL



  return LeanRC::FacadeInterface.initialize()
