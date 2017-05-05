{MainApplication} = require('../../main')::
{HttpClientApplication} = require('../../../CucumbersModule/http-client')::


module.exports = (Module) ->
  {
    APPLICATION_MEDIATOR

    SimpleCommand
    ApplicationMediator
    LoggerModuleMediator
    CucumbersModuleMediator
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

        cucumbers = HttpClientApplication.new()
        @sendNotification CONNECT_MODULE_TO_LOGGER, cucumbers
        @sendNotification CONNECT_MODULE_TO_SHELL, cucumbers
        @facade.registerMediator CucumbersModuleMediator.new cucumbers

        main = MainApplication.new()
        @sendNotification CONNECT_MODULE_TO_LOGGER, main
        @sendNotification CONNECT_MODULE_TO_SHELL, main
        @facade.registerMediator MainModuleMediator.new main
        return


  PrepareViewCommand.initialize()
