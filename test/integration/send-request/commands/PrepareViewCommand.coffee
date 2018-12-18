

module.exports = (Module) ->
  {
    NilT
    FuncG
    NotificationInterface
    ConsoleComponentMediator
    SimpleCommand
  } = Module.NS

  class PrepareViewCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: FuncG(NotificationInterface, NilT),
      default: ->
        @facade.registerMediator ConsoleComponentMediator.new ConsoleComponentMediator::CONSOLE_MEDIATOR

    @initialize()
