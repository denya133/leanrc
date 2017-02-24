RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Facade extends RC::CoreObject
    @implements LeanRC::FacadeInterface

    @public @static MULTITON_MSG: String,
      default: "Facade instance for this multiton key already constructed!"

    @public registerCommand: Function,
      default: (notificationName, aCommand)->
        @controller.registerCommand notificationName, aCommand
        return

    @public removeCommand: Function,
      default: (notificationName)->
        @controller.removeCommand notificationName
        return

    @public hasCommand: Function,
      default: (notificationName)->
        @controller.hasCommand notificationName

    @public registerProxy: Function,
      default: (proxy)->
        @model.registerProxy proxy
        return

    @public retrieveProxy: Function,
      default: (proxyName)->
        @model.retrieveProxy proxyName

    @public removeProxy: Function,
      default: (proxyName)->
        @model.removeProxy proxyName

    @public hasProxy: Function,
      default: (proxyName)->
        @model.hasProxy proxyName

    @public registerMediator: Function,
      default: (mediator)->
        if @view
          @view.registerMediator mediator
        return

    @public retrieveMediator: Function,
      default: (mediatorName)->
        if @view
          @view.retrieveMediator mediatorName

    @public removeMediator: Function,
      default: (mediatorName)->
        if @view
          @view.removeMediator mediatorName

    @public hasMediator: Function,
      default: (mediatorName)->
        if @view
          @view.hasMediator mediatorName

    @public notifyObservers: Function,
      default: (notification)->
        if @view
          @view.notifyObservers notification
        return

    @public sendNotification: Function,
      default: (name, body, type)->
        @notifyObservers LeanRC::Notification.new name, body, type
        return

    @public initializeNotifier: Function,
      default: (key)->
        @multitonKey = key
        return


    @private model: LeanRC::ModelInterface
    @private view: LeanRC::ViewInterface
    @private controller: LeanRC::ControllerInterface
    @private multitonKey: String
    @private @static instanceMap: Object,
      default: {}

    @protected initializeFacade: Function,
      default: ->
        @initializeModel()
        @initializeController()
        @initializeView()
        return

    @protected initializeModel: Function,
      default: ->
        unless @model?
          @model = LeanRC::Model.getInstance @multitonKey

    @protected initializeController: Function,
      default: ->
        unless @controller?
          @controller = LeanRC::Controller.getInstance @multitonKey
        return

    @protected initializeController: Function,
      default: ->
        unless @view?
          @view = LeanRC::View.getInstance @multitonKey
        return

    constructor: (key)->
      if Facade.instanceMap[key]
        throw new Error Facade.MULTITON_MSG
      @initializeNotifier key
      Facade.instanceMap[key] = @
      @initializeFacade()


  return LeanRC::Facade.initialize()
