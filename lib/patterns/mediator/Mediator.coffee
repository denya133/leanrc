

module.exports = (Module)->
  class Mediator extends Module::Notifier
    @inheritProtected()
    @implements Module::MediatorInterface
    @module Module

    ipsMediatorName = @private mediatorName: String
    ipoViewComponent = @private viewComponent: Module::ANY

    @public getMediatorName: Function,
      default: -> @[ipsMediatorName]

    @public getViewComponent: Function,
      default: -> @[ipoViewComponent]

    @public setViewComponent: Function,
      default: (aoViewComponent)->
        @[ipoViewComponent] = aoViewComponent
        return

    @public listNotificationInterests: Function,
      configurable: yes
      default: -> []

    @public handleNotification: Function,
      default: -> return

    @public onRegister: Function,
      default: -> return

    @public onRemove: Function,
      default: -> return

    # need test it
    @public @static @async restoreObject: Function,
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          facade = Module::ApplicationFacade.getInstance replica.multitonKey
          mediator = facade.retrieveMediator replica.mediatorName
          yield return mediator
        else
          return yield @super Module, replica

    # need test it
    @public @static @async replicateObject: Function,
      default: (instance)->
        replica = @super instance
        ipsMultitonKey = Symbol.for '~multitonKey'
        replica.multitonKey = instance[ipsMultitonKey]
        replica.mediatorName = instance.getMediatorName()
        yield return replica

    @public init: Function,
      default: (asMediatorName, aoViewComponent)->
        @super arguments...
        @[ipsMediatorName] = asMediatorName ? @constructor.name
        @[ipoViewComponent] = aoViewComponent


  Mediator.initialize()
