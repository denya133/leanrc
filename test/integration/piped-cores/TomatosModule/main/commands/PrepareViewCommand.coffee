

module.exports = (Module) ->
  {
    APPLICATION_MEDIATOR

    SimpleCommand
    MainJunctionMediator
    MainSwitch
    ApplicationMediator
  } = Module::

  class PrepareViewCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: (aoNotification)->
        voApplication = aoNotification.getBody()

        @facade.registerMediator MainJunctionMediator.new()
        @facade.registerMediator MainSwitch.new()
        @facade.registerMediator ApplicationMediator.new APPLICATION_MEDIATOR, voApplication
        return


  PrepareViewCommand.initialize()
