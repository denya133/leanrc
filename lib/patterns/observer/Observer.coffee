

module.exports = (Module)->
  {
    AnyT, NilT, PointerT, LambdaT
    FuncG, MaybeG
    ObserverInterface, NotificationInterface
    CoreObject
  } = Module::

  class Observer extends CoreObject
    @inheritProtected()
    @implements ObserverInterface
    @module Module

    ipoNotify = PointerT @private notify: MaybeG Function
    ipoContext = PointerT @private context: MaybeG AnyT

    @public setNotifyMethod: FuncG(Function, NilT),
      default: (amNotifyMethod)->
        @[ipoNotify] = amNotifyMethod
        return

    @public setNotifyContext: FuncG(AnyT, NilT),
      default: (aoNotifyContext)->
        @[ipoContext] = aoNotifyContext
        return

    @public getNotifyMethod: FuncG([], MaybeG Function),
      default: -> @[ipoNotify]

    @public getNotifyContext: FuncG([], MaybeG AnyT),
      default: -> @[ipoContext]

    @public compareNotifyContext: FuncG(AnyT, Boolean),
      default: (object)->
        object is @[ipoContext]

    @public notifyObserver: FuncG(NotificationInterface, NilT),
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

    @public init: FuncG([MaybeG(Function), MaybeG AnyT], NilT),
      default: (amNotifyMethod, aoNotifyContext)->
        @super arguments...
        @setNotifyMethod amNotifyMethod if amNotifyMethod
        @setNotifyContext aoNotifyContext if aoNotifyContext
        return


    @initialize()
