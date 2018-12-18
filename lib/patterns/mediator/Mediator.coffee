

module.exports = (Module)->
  {
    AnyT, PointerT
    FuncG, SubsetG, MaybeG
    MediatorInterface, NotificationInterface
    Notifier
  } = Module::

  class Mediator extends Notifier
    @inheritProtected()
    @implements MediatorInterface
    @module Module

    ipsMediatorName = PointerT @private mediatorName: String
    ipoViewComponent = PointerT @private viewComponent: MaybeG AnyT

    @public getMediatorName: FuncG([], String),
      default: -> @[ipsMediatorName]

    @public getViewComponent: FuncG([], MaybeG AnyT),
      default: -> @[ipoViewComponent]

    @public setViewComponent: FuncG(AnyT),
      default: (aoViewComponent)->
        @[ipoViewComponent] = aoViewComponent
        return

    @public listNotificationInterests: FuncG([], Array),
      default: -> []

    @public handleNotification: FuncG(NotificationInterface),
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

    @public init: FuncG([MaybeG(String), MaybeG AnyT]),
      default: (asMediatorName, aoViewComponent)->
        @super arguments...
        @[ipsMediatorName] = asMediatorName ? @constructor.name
        @[ipoViewComponent] = aoViewComponent if aoViewComponent?
        return


    @initialize()
