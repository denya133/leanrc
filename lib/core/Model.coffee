

module.exports = (Module)->
  {
    APPLICATION_MEDIATOR
    PointerT
    SubsetG, DictG, FuncG, StructG, MaybeG
    ProxyInterface
    ModelInterface
    CoreObject, Facade
    Utils: { _ }
  } = Module::

  class Model extends CoreObject
    @inheritProtected()
    @implements ModelInterface
    @module Module

    @const MULTITON_MSG: "Model instance for this multiton key already constructed!"

    iphProxyMap     = PointerT @private proxyMap: DictG String, MaybeG ProxyInterface
    iphMetaProxyMap = PointerT @private metaProxyMap: DictG String, MaybeG StructG {
      className: MaybeG String
      data: MaybeG Object
    }
    ipsMultitonKey  = PointerT @protected multitonKey: MaybeG String
    cphInstanceMap  = PointerT @private @static _instanceMap: DictG(String, MaybeG ModelInterface),
      default: {}
    ipcApplicationModule = PointerT @protected ApplicationModule: MaybeG SubsetG Module

    @public ApplicationModule: SubsetG(Module),
      get: ->
        @[ipcApplicationModule] ?= if @[ipsMultitonKey]?
          Facade.getInstance @[ipsMultitonKey]
            ?.retrieveMediator APPLICATION_MEDIATOR
            ?.getViewComponent()
            ?.Module ? @Module
        else
          @Module

    @public @static getInstance: FuncG(String, ModelInterface),
      default: (asKey)->
        unless Model[cphInstanceMap][asKey]?
          Model[cphInstanceMap][asKey] = Model.new asKey
        Model[cphInstanceMap][asKey]

    @public @static removeModel: FuncG(String),
      default: (asKey)->
        if (voModel = Model[cphInstanceMap][asKey])?
          for asProxyName in Reflect.ownKeys voModel[iphProxyMap]
            voModel.removeProxy asProxyName
          Model[cphInstanceMap][asKey] = undefined
          delete Model[cphInstanceMap][asKey]
        return

    @public registerProxy: FuncG(ProxyInterface),
      default: (aoProxy)->
        aoProxy.initializeNotifier @[ipsMultitonKey]
        @[iphProxyMap][aoProxy.getProxyName()] = aoProxy
        aoProxy.onRegister()
        return

    @public removeProxy: FuncG(String, MaybeG ProxyInterface),
      default: (asProxyName)->
        voProxy = @[iphProxyMap][asProxyName]
        if voProxy
          @[iphProxyMap][asProxyName] = undefined
          @[iphMetaProxyMap][asProxyName] = undefined
          delete @[iphProxyMap][asProxyName]
          delete @[iphMetaProxyMap][asProxyName]
          voProxy.onRemove()
        return voProxy

    @public retrieveProxy: FuncG(String, MaybeG ProxyInterface),
      default: (asProxyName)->
        unless @[iphProxyMap][asProxyName]?
          { className, data = {} } = @[iphMetaProxyMap][asProxyName] ? {}
          unless _.isEmpty className
            Class = (@ApplicationModule.NS ? @ApplicationModule::)[className]
            @registerProxy Class.new asProxyName, data
        @[iphProxyMap][asProxyName] ? null

    @public hasProxy: FuncG(String, Boolean),
      default: (asProxyName)->
        @[iphProxyMap][asProxyName]? or @[iphMetaProxyMap][asProxyName]?

    @public lazyRegisterProxy: FuncG([String, MaybeG(String), MaybeG Object]),
      default: (asProxyName, asProxyClassName, ahData)->
        @[iphMetaProxyMap][asProxyName] =
          className: asProxyClassName
          data: ahData
        return

    @public initializeModel: Function,
      default: ->

    @public init: FuncG(String),
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


    @initialize()
