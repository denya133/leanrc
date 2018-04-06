

module.exports = (Module)->
  class Proxy extends Module::Notifier
    @inheritProtected()
    # @implements Module::ProxyInterface
    @module Module

    ipsProxyName = @private proxyName: String
    ipoData = @private data: Module::ANY

    @public getProxyName: Function,
      default: -> @[ipsProxyName]

    @public setData: Function,
      default: (ahData)->
        @[ipoData] = ahData
        return

    @public getData: Function,
      default: -> @[ipoData]

    @public onRegister: Function,
      default: -> return

    @public onRemove: Function,
      default: -> return

    # need test it
    @public @static @async restoreObject: Function,
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          facade = Module::ApplicationFacade.getInstance replica.multitonKey
          proxy = facade.retrieveProxy replica.proxyName
          yield return proxy
        else
          return yield @super Module, replica

    # need test it
    @public @static @async replicateObject: Function,
      default: (instance)->
        replica = yield @super instance
        ipsMultitonKey = Symbol.for '~multitonKey'
        replica.multitonKey = instance[ipsMultitonKey]
        replica.proxyName = instance.getProxyName()
        yield return replica

    @public init: Function,
      default: (asProxyName, ahData)->
        @super arguments...

        @[ipsProxyName] = asProxyName ? @constructor.name

        if ahData?
          @setData ahData


  Proxy.initialize()
