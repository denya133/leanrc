# миксин может подмешиваться в наследники классa JunctionMediator

module.exports = (Module)->
  {
    LogMessage
    LogFilterMessage
    Pipes
  } = Module::
  {
    PipeAwareModule
    FilterControlMessage
  } = Pipes::
  {
    SET_PARAMS
  } = FilterControlMessage
  {
    STDLOG
  } = PipeAwareModule
  {
    SEND_TO_LOG
    LEVELS
    DEBUG
    ERROR
    FATAL
    INFO
    WARN
    CHANGE
  } = LogMessage

  Module.defineMixin (BaseClass) ->
    class LoggingJunctionMixin extends BaseClass
      @inheritProtected()

      ipoMultitonKey = Symbol.for '~multitonKey'

      @public listNotificationInterests: Function,
        default: (args...)->
          interests = @super args...
          interests.push SEND_TO_LOG
          interests.push LogFilterMessage.SET_LOG_LEVEL
          interests

      @public handleNotification: Function,
        default: (note)->
          switch note.getName()
            when SEND_TO_LOG
              switch note.getType()
                when LEVELS[DEBUG]
                  level = DEBUG
                  break
                when LEVELS[ERROR]
                  level = ERROR
                  break
                when LEVELS[FATAL]
                  level = FATAL
                  break
                when LEVELS[INFO]
                  level = INFO;
                  break
                when LEVELS[WARN]
                  level = WARN
                  break
                else
                  level = DEBUG
                  break
              logMessage = LogMessage.new level, @[ipoMultitonKey], note.getBody()
              junction.sendMessage STDLOG, logMessage
              break
            when LogFilterMessage.SET_LOG_LEVEL
              logLevel = note.getBody()
              setLogLevelMessage = LogFilterMessage.new SET_PARAMS, logLevel

              changedLevel = junction.sendMessage STDLOG, setLogLevelMessage
              changedLevelMessage = LogMessage.new CHANGE, @[ipoMultitonKey], "
                Changed Log Level to: #{LogMessage.LEVELS[logLevel]}
              "
              logChanged = junction.sendMessage STDLOG, changedLevelMessage
              break
            else
              @super note


    LoggingJunctionMixin.initializeMixin()
