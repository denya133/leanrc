RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::View extends RC::CoreObject
    @implements LeanRC::ViewInterface

    @public @static MULTITON_MSG: String,
      default: "View instance for this multiton key already constructed!"

    @public @static getInstance: Function,
      default: (key)->
        unless View.instanceMap[key]
          View.instanceMap[key] = LeanRC::View.new key
        View.instanceMap[key]

    @public @static removeView: Function,
      default: (key)->
        delete View.instanceMap[key]
        return

    @public registerObserver: Function,
      default: (aNotificationName, aObserver)->
        observers = @observerMap[aNotificationName]
        if observers
          observers.push aObserver
        else
          @observerMap[aNotificationName] = [aObserver]
        return

    @public removeObserver: Function,
      default: (aNotificationName, aNotifyContext)->
        observers = @observerMap[aNotificationName]
        for observer, index in observers
          do (observer)->
            if observer.compareNotifyContext aNotifyContext
              observers.splice index, 1
              break
        if observers.length is 0
          delete @observerMap[notificationName]
        return

    @public notifyObservers: Function,
      default: (aNotification)->
        notificationName = aNotification.getName()
        observers = @observerMap[notificationName]
        if observers
          newObservers = observersRef.slice(0)
          for observer in newObservers
            do (observer)->
              observer.notifyObserver aNotification
        return

    @public registerMediator: Function,
      default: (aMediator)->
        name = aMediator.getMediatorName()
        # Do not allow re-registration (you must removeMediator first).
        if @mediatorMap[name]
          return
        aMediator.initializeNotifier @multitonKey

        # Register the Mediator for retrieval by name.
        @mediatorMap[name] = aMediator

        # Get Notification interests, if any.
        interests = aMediator.listNotificationInterests() ? []
        if interests.length > 0
          observer = LeanRC::Observer.new aMediator.handleNotification, aMediator
          for interest in interests
            do (interest)=>
              @registerObserver interest, observer
        # Alert the mediator that it has been registered.
        aMediator.onRegister()
        return

    @public retrieveMediator: Function,
      default: (mediatorName)->
        @mediatorMap[mediatorName] ? null

    @public removeMediator: Function,
      default: (mediatorName)->
        mediator = @mediatorMap[mediatorName]
        unless mediator
          return null

        # Get Notification interests, if any.
        interests = mediator.listNotificationInterests()

        # For every notification this mediator is interested in...
        for interest in interests
          do (interest)=>
            @removeObserver interest, mediator

        # remove the mediator from the map
        delete @mediatorMap[mediatorName]

        # Alert the mediator that it has been removed
        mediator.onRemove()

        return mediator

    @public hasMediator: Function,
      default: (mediatorName)->
        @mediatorMap[mediatorName]?

    @private mediatorMap: Object
    @private observerMap: Object
    @private multitonKey: String
    @private @static instanceMap: Object,
      default: {}


    constructor: (key)->
      if View.instanceMap[key]
        throw Error View.MULTITON_MSG
      View.instanceMap[key] = @
      @multitonKey = key
      @mediatorMap = {}
      @observerMap = {}
      @initializeView()
      return

    @protected initializeView: Function,
      args: []
      return: RC::Constants.NILL
      default: ->


  return LeanRC::View.initialize()
