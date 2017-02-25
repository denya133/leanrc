RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Model extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::ModelInterface

    @Module: LeanRC

    @public @static MULTITON_MSG: String,
      default: "Model instance for this multiton key already constructed!"

    iphProxyMap     = @private proxyMap: Object
    ipsMultitonKey  = @protected multitonKey: String
    cphInstanceMap  = @private @static instanceMap: Object,
      default: {}

    @public @static getInstance: Function,
      default: (asKey)->
        unless Model[cphInstanceMap][asKey]
          Model[cphInstanceMap][asKey] = LeanRC::Model.new asKey
        Model[cphInstanceMap][asKey]

    @public @static removeModel: Function,
      default: (asKey)->
        delete Model[cphInstanceMap][asKey]
        return

    @public registerProxy: Function,
      default: (aoProxy)->
        aoProxy.initializeNotifier @[ipsMultitonKey]
        @[iphProxyMap][aoProxy.getProxyName()] = aoProxy
        aoProxy.onRegister()
        return

    @public removeProxy: Function,
      default: (asProxyName)->
        voProxy = @[iphProxyMap][asProxyName]
        if voProxy
          delete @[iphProxyMap][asProxyName]
          voProxy.onRemove()
        return voProxy

    @public retrieveProxy: Function,
      default: (asProxyName)->
        @[iphProxyMap][asProxyName] ? null

    @public hasProxy: Function,
      default: (asProxyName)->
        @[iphProxyMap][asProxyName]?

    @public initializeModel: Function,
      args: []
      return: RC::Constants.NILL
      default: ->

    constructor: (asKey)->
      if Model[cphInstanceMap][asKey]
        throw new Error Model.MULTITON_MSG
      Model[cphInstanceMap][asKey] = @
      @[ipsMultitonKey] = asKey
      @[iphProxyMap] = {}

      @initializeModel()
      return


  return LeanRC::Model.initialize()
