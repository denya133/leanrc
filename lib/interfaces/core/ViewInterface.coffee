

module.exports = (Module)->
  {
    ANY, NilT
    FuncG, UnionG, MaybeG
    ObserverInterface
    NotificationInterface
    ControllerInterface
    MediatorInterface
    Interface
  } = Module::

  class ViewInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual registerObserver: FuncG [String, ObserverInterface], NilT
    @virtual removeObserver: FuncG [String, UnionG ControllerInterface, MediatorInterface], NilT
    @virtual notifyObservers: FuncG NotificationInterface, NilT
    @virtual registerMediator: FuncG MediatorInterface, NilT
    @virtual retrieveMediator: FuncG String, MaybeG MediatorInterface
    @virtual removeMediator: FuncG String, MaybeG MediatorInterface
    @virtual hasMediator: FuncG String, Boolean


    @initialize()
