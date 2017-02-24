RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Controller extends RC::CoreObject
    @implements LeanRC::ControllerInterface

    @private @static MULTITON_MSG: String,
      default: "Controller instance for this multiton key already constructed!"

    @public @static getInstance: String,
      default: (key)->
        unless Controller.instanceMap[key]
          Controller.instanceMap[key] = LeanRC::Controller.new key
        Controller.instanceMap[key]

    @public @static removeController: String,
      args: [String]
      return: RC::Constants.NILL
      default: (key)->
        delete Controller.instanceMap[key]

    @public executeCommand: Function,
      default: (aNotification)->
        vCommand = @commandMap[aNotification.getName()]
        if vCommand?
          voCommand = vCommand.new()
          voCommand.initializeNotifier @multitonKey
          voCommand.execute aNotification
        return

    @public registerCommand: Function,
      default: (aNotificationName, aCommand)->
        unless @commandMap[aNotificationName]
          @view.registerObserver aNotificationName, LeanRC::Observer.new(@executeCommand, @)
          @commandMap[aNotificationName] = aCommand
        return

    @public hasCommand: Function,
      default: (aNotificationName)->
        @commandMap[aNotificationName]?

    @public removeCommand: Function,
      default: (aNotificationName)->
        if @hasCommand(aNotificationName)
          @view.removeObserver aNotificationName, @
          delete @commandMap[aNotificationName]
        return

    @private view: LeanRC::ViewInterface
    @private commandMap: Object
    @private multitonKey: String
    @private @static instanceMap: Object,
      default: {}

    constructor: (key)->
      if Controller.instanceMap[key]
        throw new Error Controller.MULTITON_MSG
      Controller.instanceMap[key] = @
      @multitonKey = key
      @commandMap = {}
      @initializeController()

    @protected initializeController: Function,
      args: []
      return: RC::Constants.NILL
      default: ->
        @view = LeanRC::View.getInstance @multitonKey




  return LeanRC::Controller.initialize()
