

module.exports = (Module)->
  {
    AnyT, NilT, PointerT
    FuncG, SubsetG
    MediatorInterface, NotificationInterface
    Notifier
  } = Module::

  class Mediator extends Notifier
    @inheritProtected()
    @implements MediatorInterface
    @module Module

    ipsMediatorName = PointerT @private mediatorName: String
    ipoViewComponent = PointerT @private viewComponent: AnyT

    @public getMediatorName: FuncG([], String),
      default: -> @[ipsMediatorName]

    @public getViewComponent: FuncG([], AnyT),
      default: -> @[ipoViewComponent]

    @public setViewComponent: FuncG(AnyT, NilT),
      default: (aoViewComponent)->
        @[ipoViewComponent] = aoViewComponent
        return

    @public listNotificationInterests: FuncG([], Array),
      default: -> []

    @public handleNotification: FuncG(NotificationInterface, NilT),
      default: -> return

    @public onRegister: Function,
      default: -> return

    @public onRemove: Function,
      default: -> return

    # need test it
    @public @static @async restoreObject: FuncG([SubsetG(Module), Object], MediatorInterface),
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          facade = Module::ApplicationFacade.getInstance replica.multitonKey
          mediator = facade.retrieveMediator replica.mediatorName
          yield return mediator
        else
          return yield @super Module, replica

    # need test it
    @public @static @async replicateObject: FuncG(MediatorInterface, Object),
      default: (instance)->
        replica = yield @super instance
        ipsMultitonKey = Symbol.for '~multitonKey'
        replica.multitonKey = instance[ipsMultitonKey]
        replica.mediatorName = instance.getMediatorName()
        yield return replica

    @public init: FuncG([String, AnyT], NilT),
      default: (asMediatorName, aoViewComponent)->
        @super arguments...
        @[ipsMediatorName] = asMediatorName ? @constructor.name
        @[ipoViewComponent] = aoViewComponent
        return


    @initialize()
