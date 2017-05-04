

module.exports = (Module) ->
  {
    APPLICATION_MEDIATOR

    SimpleCommand
    ApplicationMediator
    ShellJunctionMediator
  } = Module::

  class PrepareViewCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: (aoNotification)->
        voApplication = aoNotification.getBody()
        @facade.registerMediator ApplicationMediator.new APPLICATION_MEDIATOR, voApplication
        @facade.registerMediator ShellJunctionMediator.new()


  PrepareViewCommand.initialize()
