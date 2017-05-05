{MainApplication} = require('../../main')::


module.exports = (Module) ->
  {
    APPLICATION_MEDIATOR

    SimpleCommand
    ApplicationMediator
    LoggerModuleMediator
    ShellJunctionMediator
    MainModuleMediator
    Application
  } = Module::
  {
    CONNECT_MODULE_TO_LOGGER
    CONNECT_MODULE_TO_SHELL
  } = Application::

  class PrepareViewCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: (aoNotification)->
        voApplication = aoNotification.getBody()
        @facade.registerMediator LoggerModuleMediator.new()
        @facade.registerMediator ShellJunctionMediator.new()

        @facade.registerMediator ApplicationMediator.new APPLICATION_MEDIATOR, voApplication

        main = MainApplication.new()
        @sendNotification CONNECT_MODULE_TO_LOGGER, main
        @sendNotification CONNECT_MODULE_TO_SHELL, main
        @facade.registerMediator MainModuleMediator.new main
        return


  PrepareViewCommand.initialize()
