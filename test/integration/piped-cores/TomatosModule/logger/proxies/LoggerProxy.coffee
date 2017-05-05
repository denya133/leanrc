

module.exports = (Module) ->
  {
    NILL

    SimpleCommand
    LogMessageCommand
    Application
  } = Module::
  {
    LOGGER_PROXY
  } = Application::

  class LoggerProxy extends Module::Proxy
    @inheritProtected()
    @module Module

    @public messages: Array,
      get: -> @getData()

    @public addLogEntry: Function,
      args: [Object]
      return: NILL
      default: (message)->
        @messages.push message
        return

    @public init: Function,
      default: ->
        @super LOGGER_PROXY, []
        return


  LoggerProxy.initialize()
