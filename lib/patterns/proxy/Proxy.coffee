

module.exports = (Module)->
  {
    AnyT, NilT, PointerT
    FuncG, SubsetG, MaybeG
    ProxyInterface
    Notifier
  } = Module::

  class Proxy extends Notifier
    @inheritProtected()
    @implements ProxyInterface
    @module Module

    ipsProxyName = PointerT @private proxyName: String
    ipoData = PointerT @private data: MaybeG AnyT

    @public getProxyName: FuncG([], String),
      default: -> @[ipsProxyName]

    @public setData: FuncG(AnyT, NilT),
      default: (ahData)->
        @[ipoData] = ahData
        return

    @public getData: FuncG([], MaybeG AnyT),
      default: -> @[ipoData]

    @public onRegister: Function,
      default: -> return

    @public onRemove: Function,
      default: -> return

    # need test it
    @public @static @async restoreObject: FuncG([SubsetG(Module), Object], ProxyInterface),
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          facade = Module::ApplicationFacade.getInstance replica.multitonKey
          proxy = facade.retrieveProxy replica.proxyName
          yield return proxy
        else
          return yield @super Module, replica

    # need test it
    @public @static @async replicateObject: FuncG(ProxyInterface, Object),
      default: (instance)->
        replica = yield @super instance
        ipsMultitonKey = Symbol.for '~multitonKey'
        replica.multitonKey = instance[ipsMultitonKey]
        replica.proxyName = instance.getProxyName()
        yield return replica

    @public init: FuncG([MaybeG(String), MaybeG AnyT], NilT),
      default: (asProxyName, ahData)->
        @super arguments...

        @[ipsProxyName] = asProxyName ? @constructor.name

        if ahData?
          @setData ahData
        return


    @initialize()
