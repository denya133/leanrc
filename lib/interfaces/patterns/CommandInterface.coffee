

module.exports = (Module)->
  class CommandInterface extends Module::Interface
    @inheritProtected()
    @include Module::NotifierInterface

    @Module: Module

    @public @virtual execute: Function,
      args: [Module::NotificationInterface]
      return: Module::NILL


  CommandInterface.initialize()
