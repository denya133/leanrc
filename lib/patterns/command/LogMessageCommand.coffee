

module.exports = (Module) ->
  {
    SimpleCommand
    Application
  } = Module::
  {
    LOGGER_PROXY
  } = Application::

  class LogMessageCommand extends SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: (aoNotification)->
        proxy = @facade.retrieveProxy LOGGER_PROXY
        proxy.addLogEntry aoNotification.getBody()
        return


  LogMessageCommand.initialize()
