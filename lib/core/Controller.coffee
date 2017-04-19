

module.exports = (Module)->
  class Controller extends Module::CoreObject
    @inheritProtected()
    @implements Module::ControllerInterface

    @Module: Module

    @const MULTITON_MSG: "Controller instance for this multiton key already constructed!"

    ipoView         = @private view: Module::ViewInterface
    iphCommandMap   = @private commandMap: Object
    ipsMultitonKey  = @protected multitonKey: String
    cphInstanceMap  = @private @static _instanceMap: Object,
      default: {}

    @public @static getInstance: Function,
      args: [String]
      return: Module::Class
      default: (asKey)->
        unless Controller[cphInstanceMap][asKey]?
          Controller[cphInstanceMap][asKey] = Controller.new asKey
        Controller[cphInstanceMap][asKey]

    @public @static removeController: Function,
      args: [String]
      return: Module::Class
      default: (asKey)->
        delete Controller[cphInstanceMap][asKey]

    @public executeCommand: Function,
      default: (aoNotification)->
        vCommand = @[iphCommandMap][aoNotification.getName()]
        if vCommand?
          voCommand = vCommand.new()
          voCommand.initializeNotifier @[ipsMultitonKey]
          voCommand.execute aoNotification
        return

    @public registerCommand: Function,
      default: (asNotificationName, aCommand)->
        unless @[iphCommandMap][asNotificationName]
          @[ipoView].registerObserver asNotificationName, Module::Observer.new(@executeCommand, @)
          @[iphCommandMap][asNotificationName] = aCommand
        return

    @public hasCommand: Function,
      default: (asNotificationName)->
        @[iphCommandMap][asNotificationName]?

    @public removeCommand: Function,
      default: (asNotificationName)->
        if @hasCommand(asNotificationName)
          @[ipoView].removeObserver asNotificationName, @
          delete @[iphCommandMap][asNotificationName]
        return

    @public initializeController: Function,
      args: []
      return: Module::NILL
      default: ->
        @[ipoView] = Module::View.getInstance @[ipsMultitonKey]

    @public init: Function,
      default: (asKey)->
        @super arguments...
        if Controller[cphInstanceMap][asKey]
          throw new Error Controller::MULTITON_MSG
        Controller[cphInstanceMap][asKey] = @
        @[ipsMultitonKey] = asKey
        @[iphCommandMap] = {}
        @initializeController()


  Controller.initialize()
