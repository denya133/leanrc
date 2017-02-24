RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Model extends RC::CoreObject
    @implements LeanRC::ModelInterface

    @private @static MULTITON_MSG: String,
      default: "Model instance for this multiton key already constructed!"

    @public @static getInstance: Function,
      default: (key)->
        unless Model.instanceMap[key]
          Model.instanceMap[key] = LeanRC::Model.new key
        Model.instanceMap[key]

    @public @static removeModel: Function,
      default: (key)->
        delete Model.instanceMap[key]
        return

    @public registerProxy: Function,
      default: (proxy)->
        proxy.initializeNotifier @multitonKey
        @proxyMap[proxy.getProxyName()] = proxy
        proxy.onRegister()
        return

    @public removeProxy: Function,
      default: (proxyName)->
        proxy = @proxyMap[proxyName]
        if proxy
          delete @proxyMap[proxyName]
          proxy.onRemove()
        return proxy

    @public retrieveProxy: Function,
      default: (proxyName)->
        @proxyMap[proxyName] ? null

    @public hasProxy: Function,
      default: (proxyName)->
        @proxyMap[proxyName]?

    constructor: (key)->
      if Model.instanceMap[key]
        throw new Error Model.MULTITON_MSG
      Model.instanceMap[key] = @
      @multitonKey = key
      @proxyMap = {}

      @initializeModel()
      return


    @private proxyMap: Object
    @private multitonKey: String
    @private @static instanceMap: Object,
      default: {}

    @protected initializeModel: Function,
      args: []
      return: RC::Constants.NILL
      default: ->

  return LeanRC::Model.initialize()
