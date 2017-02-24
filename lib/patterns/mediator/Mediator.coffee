RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Mediator extends LeanRC::Notifier
    @implements LeanRC::MediatorInterface

    @public @static NAME: String,
      get: -> @name

    @public getMediatorName: Function,
      default: -> @mediatorName

    @public getViewComponent: Function,
      default: -> @viewComponent

    @public setViewComponent: Function,
      default: (viewComponent)->
        @viewComponent = viewComponent
        return

    @public listNotificationInterests: Function,
      default: -> []

    @public @virtual handleNotification: Function,
      default: (notification)->
        return

    @public @virtual onRegister: Function,
      default: -> return

    @public @virtual onRemove: Function,
      default: -> return


    @private mediatorName: String
    @private viewComponent: RC::Constants.ANY

    constructor: (mediatorName, viewComponent)->
      @super('constructor') arguments

      @mediatorName = mediatorName ? Mediator.NAME
      @viewComponent = viewComponent



  return LeanRC::Mediator.initialize()
