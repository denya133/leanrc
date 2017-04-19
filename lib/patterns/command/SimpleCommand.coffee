

module.exports = (Module)->
  class SimpleCommand extends Module::Notifier
    @inheritProtected()
    @implements Module::CommandInterface

    @Module: Module

    @public execute: Function,
      default: ->


  SimpleCommand.initialize()
