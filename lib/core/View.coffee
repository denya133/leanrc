

module.exports = (Module)->
  {
    PointerT
    FuncG, DictG, UnionG, MaybeG, ListG
    ViewInterface
    ObserverInterface, NotificationInterface
    MediatorInterface, ControllerInterface
    CoreObject
  } = Module::

  class View extends CoreObject
    @inheritProtected()
    @implements ViewInterface
    @module Module

    @const MULTITON_MSG: "View instance for this multiton key already constructed!"

    iphMediatorMap = PointerT @protected mediatorMap: DictG(String, MaybeG MediatorInterface)
    iphObserverMap = PointerT @protected observerMap: DictG(String, MaybeG ListG ObserverInterface)
    ipsMultitonKey = PointerT @protected multitonKey: MaybeG String
    cphInstanceMap = PointerT @private @static _instanceMap: DictG(String, MaybeG ViewInterface),
      default: {}

    @public @static getInstance: FuncG(String, ViewInterface),
      default: (asKey)->
        unless View[cphInstanceMap][asKey]?
          View[cphInstanceMap][asKey] = View.new asKey
        View[cphInstanceMap][asKey]

    @public @static removeView: FuncG(String),
      default: (asKey)->
        if (voView = View[cphInstanceMap][asKey])?
          for asMediatorName in Reflect.ownKeys voView[iphMediatorMap]
            voView.removeMediator asMediatorName
          View[cphInstanceMap][asKey] = undefined
          delete View[cphInstanceMap][asKey]
        return

    @public registerObserver: FuncG([String, ObserverInterface]),
      default: (asNotificationName, aoObserver)->
        vlObservers = @[iphObserverMap][asNotificationName]
        if vlObservers?
          vlObservers.push aoObserver
        else
          @[iphObserverMap][asNotificationName] = [aoObserver]
        return

    @public removeObserver: FuncG([String, UnionG ControllerInterface, MediatorInterface]),
      default: (asNotificationName, aoNotifyContext)->
        vlObservers = @[iphObserverMap][asNotificationName] ? []
        for voObserver, i in vlObservers
          break  if do (voObserver)->
            if voObserver.compareNotifyContext aoNotifyContext
              vlObservers[i..i] = []
              return yes
            return no
        if vlObservers.length is 0
          delete @[iphObserverMap][asNotificationName]
        return

    @public notifyObservers: FuncG(NotificationInterface),
      default: (aoNotification)->
        vsNotificationName = aoNotification.getName()
        vlObservers = @[iphObserverMap][vsNotificationName]
        if vlObservers?
          vlNewObservers = vlObservers[..]
          for voObserver in vlNewObservers
            do (voObserver)->
              voObserver.notifyObserver aoNotification
        return

    @public registerMediator: FuncG(MediatorInterface),
      default: (aoMediator)->
        vsName = aoMediator.getMediatorName()
        # Do not allow re-registration (you must removeMediator first).
        if @[iphMediatorMap][vsName]?
          return
        aoMediator.initializeNotifier @[ipsMultitonKey]

        # Register the Mediator for retrieval by name.
        @[iphMediatorMap][vsName] = aoMediator

        # Get Notification interests, if any.
        vlInterests = aoMediator.listNotificationInterests() ? []
        if vlInterests.length > 0
          voObserver = Module::Observer.new aoMediator.handleNotification, aoMediator
          for vsInterest in vlInterests
            do (vsInterest)=>
              @registerObserver vsInterest, voObserver
        # Alert the mediator that it has been registered.
        aoMediator.onRegister()
        return

    @public addMediator: FuncG(MediatorInterface),
      default: (args...)-> @registerMediator args...

    @public retrieveMediator: FuncG(String, MaybeG MediatorInterface),
      default: (asMediatorName)->
        @[iphMediatorMap][asMediatorName] ? null

    @public getMediator: FuncG(String, MaybeG MediatorInterface),
      default: (args...)-> @retrieveMediator args...

    @public removeMediator: FuncG(String, MaybeG MediatorInterface),
      default: (asMediatorName)->
        voMediator = @[iphMediatorMap][asMediatorName]
        unless voMediator?
          return null

        # Get Notification interests, if any.
        vlInterests = voMediator.listNotificationInterests()

        # For every notification this mediator is interested in...
        for vsInterest in vlInterests
          do (vsInterest)=>
            @removeObserver vsInterest, voMediator

        # remove the mediator from the map
        @[iphMediatorMap][asMediatorName] = undefined
        delete @[iphMediatorMap][asMediatorName]

        # Alert the mediator that it has been removed
        voMediator.onRemove()

        return voMediator

    @public hasMediator: FuncG(String, Boolean),
      default: (asMediatorName)->
        @[iphMediatorMap][asMediatorName]?

    @public initializeView: Function,
      default: ->

    @public init: FuncG(String),
      default: (asKey)->
        @super arguments...
        if View[cphInstanceMap][asKey]
          throw Error View::MULTITON_MSG
        View[cphInstanceMap][asKey] = @
        @[ipsMultitonKey] = asKey
        @[iphMediatorMap] = {}
        @[iphObserverMap] = {}
        @initializeView()
        return


    @initialize()
