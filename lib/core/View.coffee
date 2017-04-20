

module.exports = (Module)->
  class View extends Module::CoreObject
    @inheritProtected()
    @implements Module::ViewInterface

    @module Module

    @const MULTITON_MSG: "View instance for this multiton key already constructed!"

    iphMediatorMap = @private mediatorMap: Object
    iphObserverMap = @private observerMap: Object
    ipsMultitonKey = @protected multitonKey: String
    cphInstanceMap = @private @static _instanceMap: Object,
      default: {}

    @public @static getInstance: Function,
      default: (asKey)->
        unless View[cphInstanceMap][asKey]
          View[cphInstanceMap][asKey] = View.new asKey
        View[cphInstanceMap][asKey]

    @public @static removeView: Function,
      default: (asKey)->
        delete View[cphInstanceMap][asKey]
        return

    @public registerObserver: Function,
      default: (asNotificationName, aoObserver)->
        vlObservers = @[iphObserverMap][asNotificationName]
        if vlObservers?
          vlObservers.push aoObserver
        else
          @[iphObserverMap][asNotificationName] = [aoObserver]
        return

    @public removeObserver: Function,
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

    @public notifyObservers: Function,
      default: (aoNotification)->
        vsNotificationName = aoNotification.getName()
        vlObservers = @[iphObserverMap][vsNotificationName]
        if vlObservers?
          vlNewObservers = vlObservers[..]
          for voObserver in vlNewObservers
            do (voObserver)->
              voObserver.notifyObserver aoNotification
        return

    @public registerMediator: Function,
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

    @public retrieveMediator: Function,
      default: (asMediatorName)->
        @[iphMediatorMap][asMediatorName] ? null

    @public removeMediator: Function,
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
        delete @[iphMediatorMap][asMediatorName]

        # Alert the mediator that it has been removed
        voMediator.onRemove()

        return voMediator

    @public hasMediator: Function,
      default: (asMediatorName)->
        @[iphMediatorMap][asMediatorName]?

    @public initializeView: Function,
      args: []
      return: Module::NILL
      default: ->

    @public init: Function,
      default: (asKey)->
        @super arguments...
        if View[cphInstanceMap][asKey]
          throw Error View::MULTITON_MSG
        View[cphInstanceMap][asKey] = @
        @[ipsMultitonKey] = asKey
        @[iphMediatorMap] = {}
        @[iphObserverMap] = {}
        @initializeView()


  View.initialize()
