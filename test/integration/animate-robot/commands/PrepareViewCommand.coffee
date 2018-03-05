

module.exports = (Module) ->
  class PrepareViewCommand extends Module.NS.SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerMediator Module.NS.ConsoleComponentMediator.new Module.NS.ConsoleComponentMediator::CONSOLE_MEDIATOR

  PrepareViewCommand.initialize()
