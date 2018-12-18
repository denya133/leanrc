

module.exports = (Module)->
  {
    AnyT
    FuncG, SubsetG, MaybeG
    CommandInterface, ProxyInterface, MediatorInterface
    NotificationInterface
    NotifierInterface
  } = Module::

  class FacadeInterface extends NotifierInterface
    @inheritProtected()
    @module Module

    @virtual remove: FuncG []

    @virtual registerCommand: FuncG [String, SubsetG CommandInterface]
    @virtual removeCommand: FuncG String
    @virtual hasCommand: FuncG String, Boolean

    @virtual registerProxy: FuncG ProxyInterface
    @virtual retrieveProxy: FuncG String, MaybeG ProxyInterface
    @virtual removeProxy: FuncG String, MaybeG ProxyInterface
    @virtual hasProxy: FuncG String, Boolean

    @virtual registerMediator: FuncG MediatorInterface
    @virtual retrieveMediator: FuncG String, MaybeG MediatorInterface
    @virtual removeMediator: FuncG String, MaybeG MediatorInterface
    @virtual hasMediator: FuncG String, Boolean

    @virtual notifyObservers: FuncG NotificationInterface
    @virtual sendNotification: FuncG [String, MaybeG(AnyT), MaybeG String]


    @initialize()
