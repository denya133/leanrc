

module.exports = (Module)->
  class Mediator extends Module::Notifier
    @inheritProtected()
    @implements Module::MediatorInterface

    @Module: Module

    ipsMediatorName = @private mediatorName: String
    ipoViewComponent = @private viewComponent: Module::ANY

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

    @public init: Function,
      default: (asMediatorName, aoViewComponent)->
        @super arguments...
        @[ipsMediatorName] = asMediatorName ? @constructor.name
        @[ipoViewComponent] = aoViewComponent


  Mediator.initialize()
