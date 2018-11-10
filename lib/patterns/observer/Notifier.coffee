

module.exports = (Module)->
  {
    AnyT, NilT, PointerT
    FuncG, SubsetG, MaybeG
    NotifierInterface
    FacadeInterface
    CoreObject
  } = Module::

  class Notifier extends CoreObject
    @inheritProtected()
    @implements NotifierInterface
    @module Module

    @const MULTITON_MSG: "multitonKey for this Notifier not yet initialized!"

    ipsMultitonKey = PointerT @protected multitonKey: String
    ipcApplicationModule = PointerT @protected ApplicationModule: SubsetG Module

    @public facade: FacadeInterface,
      get: ->
        unless @[ipsMultitonKey]?
          throw new Error Notifier::MULTITON_MSG
        Module::Facade.getInstance @[ipsMultitonKey]

    @public sendNotification: FuncG([String, MaybeG(AnyT), String], NilT),
      default: (asName, aoBody, asType)->
        @facade?.sendNotification asName, aoBody, asType
        return

    @public initializeNotifier: FuncG(String, NilT),
      default: (asKey)->
        @[ipsMultitonKey] = asKey
        return

    @public ApplicationModule: SubsetG(Module),
      get: ->
        @[ipcApplicationModule] ?= if @[ipsMultitonKey]?
          Module::Facade.getInstance @[ipsMultitonKey]
            ?.retrieveMediator Module::APPLICATION_MEDIATOR
            ?.getViewComponent()
            ?.Module ? @Module
        else
          @Module


    @initialize()
