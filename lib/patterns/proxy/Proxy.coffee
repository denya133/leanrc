

module.exports = (Module)->
  class Proxy extends Module::Notifier
    @inheritProtected()
    @module Module
    @implements Module::ProxyInterface

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

    @public init: Function,
      default: (asProxyName, ahData)->
        @super arguments...

        @[ipsProxyName] = asProxyName ? @constructor.name

        if ahData?
          @setData ahData


  Proxy.initialize()
