

module.exports = (Module)->
  {
    NilT
    FuncG, SubsetG
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
    @virtual retrieveProxy: FuncG String, ProxyInterface
    @virtual removeProxy: FuncG String, ProxyInterface
    @virtual hasProxy: FuncG String, Boolean

    @virtual registerMediator: FuncG MediatorInterface, NilT
    @virtual retrieveMediator: FuncG String, MediatorInterface
    @virtual removeMediator: FuncG String, MediatorInterface
    @virtual hasMediator: FuncG String, Boolean

    @virtual notifyObservers: FuncG NotificationInterface, NilT


    @initialize()
