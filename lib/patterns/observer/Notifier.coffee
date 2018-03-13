

module.exports = (Module)->
  class Notifier extends Module::CoreObject
    @inheritProtected()
    # @implements Module::NotifierInterface
    @module Module

    @const MULTITON_MSG: "multitonKey for this Notifier not yet initialized!"

    ipsMultitonKey = @protected multitonKey: String
    ipcApplicationModule = @protected ApplicationModule: Module::Class

    @public facade: Module::FacadeInterface,
      get: ->
        unless @[ipsMultitonKey]?
          throw new Error Notifier::MULTITON_MSG
        Module::Facade.getInstance @[ipsMultitonKey]

    @public sendNotification: Function,
      default: (asName, aoBody, asType)->
        @facade?.sendNotification asName, aoBody, asType
        return

    @public initializeNotifier: Function,
      default: (asKey)->
        @[ipsMultitonKey] = asKey
        return

    @public ApplicationModule: Module::Class,
      get: ->
        @[ipcApplicationModule] ?= if @[ipsMultitonKey]?
          Module::Facade.getInstance @[ipsMultitonKey]
            ?.retrieveMediator Module::APPLICATION_MEDIATOR
            ?.getViewComponent()
            ?.Module ? @Module
        else
          @Module


  Notifier.initialize()
