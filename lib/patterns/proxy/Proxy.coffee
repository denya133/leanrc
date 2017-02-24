RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Proxy extends LeanRC::Notifier
    @implements LeanRC::ProxyInterface

    @public @static NAME: String,
      get: -> @name

    @public getProxyName: Function,
      default: -> @proxyName

    @public setData: Function,
      default: (data)->
        @data = data
        return

    @public getData: Function,
      default: -> @data

    @public onRegister: Function,
      default: ->
        return

    @public onRemove: Function,
      default: ->
        return


    @private proxyName: String
    @private data: RC::Constants.ANY

    constructor: (proxyName, data)->
      @super arguments...

      @proxyName = proxyName ? Proxy.NAME

      if data?
        @setData data



  return LeanRC::Proxy.initialize()
