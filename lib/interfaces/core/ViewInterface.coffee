

module.exports = (Module)->
  {
    ANY
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

    @virtual registerObserver: FuncG [String, ObserverInterface]
    @virtual removeObserver: FuncG [String, UnionG ControllerInterface, MediatorInterface]
    @virtual notifyObservers: FuncG NotificationInterface
    @virtual registerMediator: FuncG MediatorInterface
    @virtual retrieveMediator: FuncG String, MaybeG MediatorInterface
    @virtual removeMediator: FuncG String, MaybeG MediatorInterface
    @virtual hasMediator: FuncG String, Boolean


    @initialize()
