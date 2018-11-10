

module.exports = (Module)->
  {
    AnyT, NilT, PointerT, LambdaT
    FuncG
    ObserverInterface, NotificationInterface
    CoreObject
  } = Module::

  class Observer extends CoreObject
    @inheritProtected()
    @implements ObserverInterface
    @module Module

    ipoNotify = PointerT @private notify: LambdaT
    ipoContext = PointerT @private context: AnyT

    @public setNotifyMethod: FuncG(Function, NilT),
      default: (amNotifyMethod)->
        @[ipoNotify] = amNotifyMethod
        return

    @public setNotifyContext: FuncG(AnyT, NilT),
      default: (aoNotifyContext)->
        @[ipoContext] = aoNotifyContext
        return

    @public getNotifyMethod: FuncG([], Function),
      default: -> @[ipoNotify]

    @public getNotifyContext: FuncG([], AnyT),
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

    @public init: FuncG([Function, AnyT], NilT),
      default: (amNotifyMethod, aoNotifyContext)->
        @super arguments...
        @setNotifyMethod amNotifyMethod
        @setNotifyContext aoNotifyContext
        return


    @initialize()
