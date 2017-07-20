

module.exports = (Module) ->
  {
    APPLICATION_MEDIATOR

    SimpleCommand
    ApplicationMediator
  } = Module::

  class PrepareViewCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: (aoNotification)->
        voApplication = aoNotification.getBody()
        @facade.registerMediator ApplicationMediator.new APPLICATION_MEDIATOR, voApplication


  PrepareViewCommand.initialize()
