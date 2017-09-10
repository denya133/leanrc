

module.exports = (Module) ->
  class PrepareViewCommand extends Module::SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        @facade.registerMediator Module::ConsoleComponentMediator.new Module::ConsoleComponentMediator::CONSOLE_MEDIATOR

  PrepareViewCommand.initialize()
