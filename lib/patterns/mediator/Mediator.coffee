RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Mediator extends LeanRC::Notifier
    @inheritProtected()
    @implements LeanRC::MediatorInterface

    @Module: LeanRC

    ipsMediatorName = @private mediatorName: String
    ipoViewComponent = @private viewComponent: RC::Constants.ANY

    @public getMediatorName: Function,
      default: -> @[ipsMediatorName]

    @public getViewComponent: Function,
      default: -> @[ipoViewComponent]

    @public setViewComponent: Function,
      default: (aoViewComponent)->
        @[ipoViewComponent] = aoViewComponent
        return

    @public listNotificationInterests: Function,
      configurable: yes
      default: -> []

    @public handleNotification: Function,
      default: -> return

    @public onRegister: Function,
      default: -> return

    @public onRemove: Function,
      default: -> return

    constructor: (asMediatorName, aoViewComponent)->
      super arguments...

      @[ipsMediatorName] = asMediatorName ? @constructor.name
      @[ipoViewComponent] = aoViewComponent


  return LeanRC::Mediator.initialize()
