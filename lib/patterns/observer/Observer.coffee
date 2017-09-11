

module.exports = (Module)->
  {ANY, NILL} = Module::

  class Observer extends Module::CoreObject
    @inheritProtected()
    # @implements Module::ObserverInterface
    @module Module

    ipoNotify = @private notify: ANY
    ipoContext = @private context: ANY

    @public setNotifyMethod: Function,
      default: (amNotifyMethod)->
        @[ipoNotify] = amNotifyMethod
        return

    @public setNotifyContext: Function,
      default: (aoNotifyContext)->
        @[ipoContext] = aoNotifyContext
        return

    @public getNotifyMethod: Function,
      default: -> @[ipoNotify]

    @public getNotifyContext: Function,
      default: -> @[ipoContext]

    @public compareNotifyContext: Function,
      default: (object)->
        object is @[ipoContext]

    @public notifyObserver: Function,
      default: (notification)->
        @getNotifyMethod().call @getNotifyContext(), notification
        return

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: Function,
      default: (amNotifyMethod, aoNotifyContext)->
        @super arguments...
        @setNotifyMethod amNotifyMethod
        @setNotifyContext aoNotifyContext



  Observer.initialize()
