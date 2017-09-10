

module.exports = (Module)->
  Module.defineInterface (BaseClass) ->
    class CommandInterface extends BaseClass
      @inheritProtected()
      @include Module::NotifierInterface

      @public @virtual execute: Function,
        args: [Module::NotificationInterface]
        return: Module::NILL


    CommandInterface.initializeInterface()
