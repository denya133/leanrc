RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Proxy extends LeanRC::Notifier
    @implements LeanRC::ProxyInterface

    ipsProxyName = @private proxyName: String
    ipoData = @private data: RC::Constants.ANY

    @public getProxyName: Function,
      default: -> @[ipsProxyName]

    @public setData: Function,
      default: (data)->
        @[ipoData] = data
        return

    @public getData: Function,
      default: -> @[ipoData]

    @public onRegister: Function,
      default: -> return

    @public onRemove: Function,
      default: -> return

    constructor: (proxyName, data)->
      @super arguments...

      @[ipsProxyName] = proxyName ? @constructor.name

      if data?
        @setData data


  return LeanRC::Proxy.initialize()
