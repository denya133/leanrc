

module.exports = (Module)->
  {
    APPLICATION_MEDIATOR
    AnyT, PointerT
    FuncG, SubsetG, DictG, MaybeG
    FacadeInterface
    ModelInterface, ViewInterface, ControllerInterface
    CommandInterface, ProxyInterface, MediatorInterface
    NotificationInterface
    CoreObject
  } = Module::

  class Facade extends CoreObject
    @inheritProtected()
    @implements FacadeInterface
    @module Module

    @const MULTITON_MSG: "Facade instance for this multiton key already constructed!"

    ipoModel        = PointerT @protected model: MaybeG ModelInterface
    ipoView         = PointerT @protected view: MaybeG ViewInterface
    ipoController   = PointerT @protected controller: MaybeG ControllerInterface
    ipsMultitonKey  = PointerT @protected multitonKey: MaybeG String
    cphInstanceMap  = PointerT @protected @static instanceMap: DictG(String, MaybeG FacadeInterface),
      default: {}

    ipmInitializeModel = PointerT @protected initializeModel: Function,
      default: ->
        unless @[ipoModel]?
          @[ipoModel] = Module::Model.getInstance @[ipsMultitonKey]
        return

    ipmInitializeController = PointerT @protected initializeController: Function,
      default: ->
        unless @[ipoController]?
          @[ipoController] = Module::Controller.getInstance @[ipsMultitonKey]
        return

    ipmInitializeView = PointerT @protected initializeView: Function,
      default: ->
        unless @[ipoView]?
          @[ipoView] = Module::View.getInstance @[ipsMultitonKey]
        return

    ipmInitializeFacade = PointerT @protected initializeFacade: Function,
      default: ->
        @[ipmInitializeModel]()
        @[ipmInitializeController]()
        @[ipmInitializeView]()
        return

    @public @static getInstance: FuncG(String, FacadeInterface),
      default: (asKey)->
        unless Facade[cphInstanceMap][asKey]?
          Facade[cphInstanceMap][asKey] = Facade.new asKey
        Facade[cphInstanceMap][asKey]

    @public remove: FuncG([]),
      default: ->
        Module::Model.removeModel @[ipsMultitonKey]
        Module::Controller.removeController @[ipsMultitonKey]
        Module::View.removeView @[ipsMultitonKey]
        @[ipoModel] = undefined
        @[ipoView] = undefined
        @[ipoController] = undefined
        Module::Facade[cphInstanceMap][@[ipsMultitonKey]] = undefined
        delete Module::Facade[cphInstanceMap][@[ipsMultitonKey]]
        return

    @public registerCommand: FuncG([String, SubsetG CommandInterface]),
      default: (asNotificationName, aCommand)->
        @[ipoController].registerCommand asNotificationName, aCommand
        return

    @public lazyRegisterCommand: FuncG([String, String]),
      default: (asNotificationName, asClassName)->
        @[ipoController].lazyRegisterCommand asNotificationName, asClassName
        return

    @public removeCommand: FuncG(String),
      default: (asNotificationName)->
        @[ipoController].removeCommand asNotificationName
        return

    @public hasCommand: FuncG(String, Boolean),
      default: (asNotificationName)->
        @[ipoController].hasCommand asNotificationName

    @public registerProxy: FuncG(ProxyInterface),
      default: (aoProxy)->
        @[ipoModel].registerProxy aoProxy
        return

    @public lazyRegisterProxy: FuncG([String, String, Object]),
      default: (asProxyName, asProxyClassName, ahData)->
        @[ipoModel].lazyRegisterProxy asProxyName, asProxyClassName, ahData
        return

    @public retrieveProxy: FuncG(String, MaybeG ProxyInterface),
      default: (asProxyName)->
        @[ipoModel].retrieveProxy asProxyName

    @public removeProxy: FuncG(String, MaybeG ProxyInterface),
      default: (asProxyName)->
        @[ipoModel].removeProxy asProxyName

    @public hasProxy: FuncG(String, Boolean),
      default: (asProxyName)->
        @[ipoModel].hasProxy asProxyName

    @public registerMediator: FuncG(MediatorInterface),
      default: (aoMediator)->
        if @[ipoView]
          @[ipoView].registerMediator aoMediator
        return

    @public retrieveMediator: FuncG(String, MaybeG MediatorInterface),
      default: (asMediatorName)->
        if @[ipoView]
          @[ipoView].retrieveMediator asMediatorName

    @public removeMediator: FuncG(String, MaybeG MediatorInterface),
      default: (asMediatorName)->
        if @[ipoView]
          @[ipoView].removeMediator asMediatorName

    @public hasMediator: FuncG(String, Boolean),
      default: (asMediatorName)->
        if @[ipoView]
          @[ipoView].hasMediator asMediatorName

    @public notifyObservers: FuncG(NotificationInterface),
      default: (aoNotification)->
        if @[ipoView]
          @[ipoView].notifyObservers aoNotification
        return

    @public sendNotification: FuncG([String, MaybeG(AnyT), MaybeG String]),
      default: (asName, aoBody, asType)->
        @notifyObservers Module::Notification.new asName, aoBody, asType
        return

    @public initializeNotifier: FuncG(String),
      default: (asKey)->
        @[ipsMultitonKey] = asKey
        return

    # need test it
    @public @static @async restoreObject: FuncG([SubsetG(Module), Object], FacadeInterface),
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          unless Facade[cphInstanceMap][replica.multitonKey]?
            Module::[replica.application].new()
          facade = Module::ApplicationFacade.getInstance replica.multitonKey
          yield return facade
        else
          return yield @super Module, replica

    # need test it
    @public @static @async replicateObject: FuncG(FacadeInterface, Object),
      default: (instance)->
        replica = yield @super instance
        replica.multitonKey = instance[ipsMultitonKey]
        applicationMediator = instance.retrieveMediator APPLICATION_MEDIATOR
        application = applicationMediator.getViewComponent().constructor.name
        replica.application = application
        yield return replica

    @public init: FuncG(String),
      default: (asKey)->
        @super arguments...
        if Facade[cphInstanceMap][asKey]?
          throw new Error Facade::MULTITON_MSG
        @initializeNotifier asKey
        Facade[cphInstanceMap][asKey] = @
        @[ipmInitializeFacade]()
        return


    @initialize()
