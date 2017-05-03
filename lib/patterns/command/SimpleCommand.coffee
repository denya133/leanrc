

module.exports = (Module)->
  class SimpleCommand extends Module::Notifier
    @inheritProtected()
    @module Module
    @implements Module::CommandInterface

    @public execute: Function,
      default: ->


  SimpleCommand.initialize()
