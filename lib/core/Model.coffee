

module.exports = (Module)->
  {
    APPLICATION_MEDIATOR

    Facade
    Utils: { _ }
  } = Module::
  class Model extends Module::CoreObject
    @inheritProtected()
    # @implements Module::ModelInterface
    @module Module

    @const MULTITON_MSG: "Model instance for this multiton key already constructed!"

    iphProxyMap     = @private proxyMap: Object
    iphMetaProxyMap = @private metaProxyMap: Object
    ipsMultitonKey  = @protected multitonKey: String
    cphInstanceMap  = @private @static _instanceMap: Object,
      default: {}
    ipcApplicationModule = @protected ApplicationModule: Module::Class

    @public ApplicationModule: Module::Class,
      get: ->
        @[ipcApplicationModule] ?= if @[ipsMultitonKey]?
          Facade.getInstance @[ipsMultitonKey]
            ?.retrieveMediator APPLICATION_MEDIATOR
            ?.getViewComponent()
            ?.Module ? @Module
        else
          @Module

    @public @static getInstance: Function,
      default: (asKey)->
        unless Model[cphInstanceMap][asKey]?
          Model[cphInstanceMap][asKey] = Model.new asKey
        Model[cphInstanceMap][asKey]

    @public @static removeModel: Function,
      default: (asKey)->
        if (voModel = Model[cphInstanceMap][asKey])?
          for asProxyName in Reflect.ownKeys voModel[iphProxyMap]
            voModel.removeProxy asProxyName
          Model[cphInstanceMap][asKey] = undefined
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
          @[iphProxyMap][asProxyName] = undefined
          @[iphMetaProxyMap][asProxyName] = undefined
          delete @[iphProxyMap][asProxyName]
          delete @[iphMetaProxyMap][asProxyName]
          voProxy.onRemove()
        return voProxy

    @public retrieveProxy: Function,
      default: (asProxyName)->
        unless @[iphProxyMap][asProxyName]?
          { className, data = {} } = @[iphMetaProxyMap][asProxyName] ? {}
          unless _.isEmpty className
            Class = @ApplicationModule::[className]
            @registerProxy Class.new asProxyName, data
        @[iphProxyMap][asProxyName] ? null

    @public hasProxy: Function,
      default: (asProxyName)->
        @[iphProxyMap][asProxyName]? or @[iphMetaProxyMap][asProxyName]?

    @public lazyRegisterProxy: Function,
      default: (asProxyName, asProxyClassName, ahData)->
        @[iphMetaProxyMap][asProxyName] =
          className: asProxyClassName
          data: ahData
        return

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
        @[iphMetaProxyMap] = {}

        @initializeModel()
        return


  Model.initialize()
