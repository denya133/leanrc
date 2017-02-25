RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::FacadeInterface extends RC::Interface
    @inheritProtected()
    @include LeanRC::NotifierInterface

    @Module: LeanRC

    @public @virtual registerCommand: Function,
      args: [String, RC::Class]
      return: RC::Constants.NILL
    @public @virtual removeCommand: Function,
      args: [String]
      return: RC::Constants.NILL
    @public @virtual hasCommand: Function,
      args: [String]
      return: Boolean

    @public @virtual registerProxy: Function,
      args: [LeanRC::ProxyInterface]
      return: RC::Constants.NILL
    @public @virtual retrieveProxy: Function,
      args: [String]
      return: LeanRC::ProxyInterface
    @public @virtual removeProxy: Function,
      args: [String]
      return: LeanRC::ProxyInterface
    @public @virtual hasProxy: Function,
      args: [String]
      return: Boolean

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

    @public @virtual notifyObservers: Function,
      args: [LeanRC::NotificationInterface]
      return: RC::Constants.NILL


  return LeanRC::FacadeInterface.initialize()
