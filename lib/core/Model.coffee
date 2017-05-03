

module.exports = (Module)->
  class Model extends Module::CoreObject
    @inheritProtected()
    @implements Module::ModelInterface
    @module Module

    @const MULTITON_MSG: "Model instance for this multiton key already constructed!"

    iphProxyMap     = @private proxyMap: Object
    ipsMultitonKey  = @protected multitonKey: String
    cphInstanceMap  = @private @static _instanceMap: Object,
      default: {}

    @public @static getInstance: Function,
      default: (asKey)->
        unless Model[cphInstanceMap][asKey]?
          Model[cphInstanceMap][asKey] = Model.new asKey
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
      return: Module::NILL
      default: ->

    @public init: Function,
      default: (asKey)->
        @super arguments...
        if Model[cphInstanceMap][asKey]
          throw new Error Model::MULTITON_MSG
        Model[cphInstanceMap][asKey] = @
        @[ipsMultitonKey] = asKey
        @[iphProxyMap] = {}

        @initializeModel()
        return


  Model.initialize()
