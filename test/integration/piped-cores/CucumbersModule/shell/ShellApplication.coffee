

module.exports = (Module) ->
  {
    NILL

    LogMessage
    LogFilterMessage
    Application
  } = Module::

  class ShellApplication extends Application
    @inheritProtected()
    @module Module

    @public @static NAME: String,
      default: 'CucumbersShell'

    @public setLogLevelMethod: Function,
      args: []
      return: NILL
      default: (level)->
        @facade.sendNotification LogFilterMessage.SET_LOG_LEVEL, level

    @public init: Function,
      default: (args...)->
        @super args...
        @setLogLevelMethod LogMessage.DEBUG
        return


  ShellApplication.initialize()
