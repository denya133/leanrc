RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Proxy extends LeanRC::Notifier
    @inheritProtected()
    @implements LeanRC::ProxyInterface

    @Module: LeanRC

    ipsProxyName = @private proxyName: String
    ipoData = @private data: RC::Constants.ANY

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

    constructor: (asProxyName, ahData)->
      @super arguments...

      @[ipsProxyName] = asProxyName ? @constructor.name

      if ahData?
        @setData ahData


  return LeanRC::Proxy.initialize()
