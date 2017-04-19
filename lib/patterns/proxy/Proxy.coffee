RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Proxy extends LeanRC::Notifier
    @inheritProtected()
    @implements LeanRC::ProxyInterface

    @Module: LeanRC

    ipsProxyName = @private _proxyName: String
    ipoData = @private _data: RC::Constants.ANY

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
      super arguments...

      console.log 'CREATE PROXY NAME: ', asProxyName
      @[ipsProxyName] = asProxyName ? @constructor.name

      if ahData?
        @setData ahData


  return LeanRC::Proxy.initialize()
