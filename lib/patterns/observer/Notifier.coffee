

module.exports = (Module)->
  class Notifier extends Module::CoreObject
    @inheritProtected()
    # @implements Module::NotifierInterface
    @module Module

    @const MULTITON_MSG: "multitonKey for this Notifier not yet initialized!"

    ipsMultitonKey = @protected multitonKey: String
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


  Notifier.initialize()
