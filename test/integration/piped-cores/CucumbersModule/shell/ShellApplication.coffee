

module.exports = (Module) ->
  {
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


  ShellApplication.initialize()
