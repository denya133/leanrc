

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface 'ViewInterface', (BaseClass) ->
    class extends BaseClass
      @inheritProtected()
      @module Module

      @public @virtual registerObserver: Function,
        args: [String, Module::ObserverInterface]
        return: NILL
      @public @virtual removeObserver: Function,
        args: [String, ANY]
        return: NILL
      @public @virtual notifyObservers: Function,
        args: [Module::NotificationInterface]
        return: NILL
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


      @initializeInterface()
