

module.exports = (Module)->
  {ANY, NILL} = Module::

  class FacadeInterface extends Module::Interface
    @inheritProtected()
    @include Module::NotifierInterface

    @module Module

    @public @virtual registerCommand: Function,
      args: [String, Module::Class]
      return: NILL
    @public @virtual removeCommand: Function,
      args: [String]
      return: NILL
    @public @virtual hasCommand: Function,
      args: [String]
      return: Boolean

    @public @virtual registerProxy: Function,
      args: [Module::ProxyInterface]
      return: NILL
    @public @virtual retrieveProxy: Function,
      args: [String]
      return: Module::ProxyInterface
    @public @virtual removeProxy: Function,
      args: [String]
      return: Module::ProxyInterface
    @public @virtual hasProxy: Function,
      args: [String]
      return: Boolean

    @public @virtual registerMediator: Function,
      args: [Module::MediatorInterface]
      return: NILL
    @public @virtual retrieveMediator: Function,
      args: [String]
      return: Module::MediatorInterface
    @public @virtual removeMediator: Function,
      args: [String]
      return: Module::MediatorInterface
    @public @virtual hasMediator: Function,
      args: [String]
      return: Boolean

    @public @virtual notifyObservers: Function,
      args: [Module::NotificationInterface]
      return: NILL


  FacadeInterface.initialize()
