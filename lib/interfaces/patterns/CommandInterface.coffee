

module.exports = (Module)->
  class CommandInterface extends Module::Interface
    @inheritProtected()
    @include Module::NotifierInterface

    @module Module

    @public @virtual execute: Function,
      args: [Module::NotificationInterface]
      return: Module::NILL


  CommandInterface.initialize()
