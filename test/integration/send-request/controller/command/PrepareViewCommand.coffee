

module.exports = (Module) ->
  class PrepareViewCommand extends Module::SimpleCommand
    @inheritProtected()
    @Module: Module

    @public execute: Function,
      default: ->
        @facade.registerMediator Module::ConsoleComponentMediator.new Module::ConsoleComponentMediator::CONSOLE_MEDIATOR

  PrepareViewCommand.initialize()
