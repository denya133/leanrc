

module.exports = (Module)->
  Module.defineInterface 'CommandInterface', (BaseClass) ->
    class CommandInterface extends BaseClass
      @inheritProtected()
      @include Module::NotifierInterface

      @module Module

      @public @virtual execute: Function,
        args: [Module::NotificationInterface]
        return: Module::NILL


    CommandInterface.initializeInterface()
