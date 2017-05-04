{CoreApplication} = require('../../core')::
{HttpClientApplication} = require('../../../CucumbersModule/http-client')::


module.exports = (Module) ->
  {
    APPLICATION_MEDIATOR

    SimpleCommand
    ApplicationMediator
    LoggerModuleMediator
    CucumbersModuleMediator
    ShellJunctionMediator
    CoreModuleMediator
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

        core = CoreApplication.new()
        @sendNotification CONNECT_MODULE_TO_LOGGER, core
        @sendNotification CONNECT_MODULE_TO_SHELL, core
        @facade.registerMediator CoreModuleMediator.new core
        return


  PrepareViewCommand.initialize()
