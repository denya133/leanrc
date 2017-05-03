

module.exports = (Module)->
  class Facade extends Module::CoreObject
    @inheritProtected()
    @implements Module::FacadeInterface
    @module Module

    @const MULTITON_MSG: "Facade instance for this multiton key already constructed!"

    ipoModel        = @private model: Module::ModelInterface
    ipoView         = @private view: Module::ViewInterface
    ipoController   = @private controller: Module::ControllerInterface
    ipsMultitonKey  = @protected multitonKey: String
    cphInstanceMap  = @protected @static instanceMap: Object,
      default: {}

    ipmInitializeModel = @protected initializeModel: Function,
      default: ->
        unless @[ipoModel]?
          @[ipoModel] = Module::Model.getInstance @[ipsMultitonKey]

    ipmInitializeController = @protected initializeController: Function,
      default: ->
        unless @[ipoController]?
          @[ipoController] = Module::Controller.getInstance @[ipsMultitonKey]
        return

    ipmInitializeView = @protected initializeView: Function,
      default: ->
        unless @[ipoView]?
          @[ipoView] = Module::View.getInstance @[ipsMultitonKey]
        return

    ipmInitializeFacade = @protected initializeFacade: Function,
      default: ->
        @[ipmInitializeModel]()
        @[ipmInitializeController]()
        @[ipmInitializeView]()
        return

    @public @static getInstance: Function,
      default: (asKey)->
        unless Facade[cphInstanceMap][asKey]?
          Facade[cphInstanceMap][asKey] = Facade.new asKey
        Facade[cphInstanceMap][asKey]

    @public registerCommand: Function,
      default: (asNotificationName, aCommand)->
        @[ipoController].registerCommand asNotificationName, aCommand
        return

    @public removeCommand: Function,
      default: (asNotificationName)->
        @[ipoController].removeCommand asNotificationName
        return

    @public hasCommand: Function,
      default: (asNotificationName)->
        @[ipoController].hasCommand asNotificationName

    @public registerProxy: Function,
      default: (aoProxy)->
        @[ipoModel].registerProxy aoProxy
        return

    @public retrieveProxy: Function,
      default: (asProxyName)->
        @[ipoModel].retrieveProxy asProxyName

    @public removeProxy: Function,
      default: (asProxyName)->
        @[ipoModel].removeProxy asProxyName

    @public hasProxy: Function,
      default: (asProxyName)->
        @[ipoModel].hasProxy asProxyName

    @public registerMediator: Function,
      default: (aoMediator)->
        if @[ipoView]
          @[ipoView].registerMediator aoMediator
        return

    @public retrieveMediator: Function,
      default: (asMediatorName)->
        if @[ipoView]
          @[ipoView].retrieveMediator asMediatorName

    @public removeMediator: Function,
      default: (asMediatorName)->
        if @[ipoView]
          @[ipoView].removeMediator asMediatorName

    @public hasMediator: Function,
      default: (asMediatorName)->
        if @[ipoView]
          @[ipoView].hasMediator asMediatorName

    @public notifyObservers: Function,
      default: (aoNotification)->
        if @[ipoView]
          @[ipoView].notifyObservers aoNotification
        return

    @public sendNotification: Function,
      default: (asName, asBody, asType)->
        @notifyObservers Module::Notification.new asName, asBody, asType
        return

    @public initializeNotifier: Function,
      default: (asKey)->
        @[ipsMultitonKey] = asKey
        return

    @public init: Function,
      default: (asKey)->
        @super arguments...
        if Facade[cphInstanceMap][asKey]?
          throw new Error Facade::MULTITON_MSG
        @initializeNotifier asKey
        Facade[cphInstanceMap][asKey] = @
        @[ipmInitializeFacade]()


  Facade.initialize()
