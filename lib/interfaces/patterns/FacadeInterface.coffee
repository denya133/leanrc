

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, SubsetG, MaybeG
    CommandInterface, ProxyInterface, MediatorInterface
    NotificationInterface
    NotifierInterface
  } = Module::

  class FacadeInterface extends NotifierInterface
    @inheritProtected()
    @module Module

    @virtual remove: FuncG [], NilT

    @virtual registerCommand: FuncG [String, SubsetG CommandInterface], NilT
    @virtual removeCommand: FuncG String, NilT
    @virtual hasCommand: FuncG String, Boolean

    @virtual registerProxy: FuncG ProxyInterface, NilT
    @virtual retrieveProxy: FuncG String, MaybeG ProxyInterface
    @virtual removeProxy: FuncG String, MaybeG ProxyInterface
    @virtual hasProxy: FuncG String, Boolean

    @virtual registerMediator: FuncG MediatorInterface, NilT
    @virtual retrieveMediator: FuncG String, MaybeG MediatorInterface
    @virtual removeMediator: FuncG String, MaybeG MediatorInterface
    @virtual hasMediator: FuncG String, Boolean

    @virtual notifyObservers: FuncG NotificationInterface, NilT
    @virtual sendNotification: FuncG [String, MaybeG(AnyT), MaybeG String], NilT


    @initialize()
