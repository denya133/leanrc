

module.exports = (Module)->
  class SimpleCommand extends Module::Notifier
    @inheritProtected()
    @implements Module::CommandInterface

    @module Module

    @public execute: Function,
      default: ->


  SimpleCommand.initialize()
