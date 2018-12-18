# миксин может подмешиваться в наследники классa JunctionMediator

module.exports = (Module)->
  {
    LogMessage
    LogFilterMessage
    Pipes
    Mixin
    NilT, PointerT
    FuncG
    NotificationInterface
  } = Module::
  {
    JunctionMediator
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

  Module.defineMixin Mixin 'LoggingJunctionMixin', (BaseClass = JunctionMediator) ->
    class extends BaseClass
      @inheritProtected()

      ipoMultitonKey = PointerT Symbol.for '~multitonKey'
      ipoJunction = PointerT Symbol.for '~junction'

      @public listNotificationInterests: FuncG([], Array),
        default: (args...)->
          interests = @super args...
          interests.push SEND_TO_LOG
          interests.push LogFilterMessage.SET_LOG_LEVEL
          interests

      @public handleNotification: FuncG(NotificationInterface, NilT),
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
                  level = INFO
                  break
                when LEVELS[WARN]
                  level = WARN
                  break
                else
                  level = DEBUG
                  break
              logMessage = LogMessage.new level, @[ipoMultitonKey], note.getBody()
              @[ipoJunction].sendMessage STDLOG, logMessage
              break
            when LogFilterMessage.SET_LOG_LEVEL
              logLevel = note.getBody()
              setLogLevelMessage = LogFilterMessage.new SET_PARAMS, logLevel

              @[ipoJunction].sendMessage STDLOG, setLogLevelMessage
              changedLevelMessage = LogMessage.new CHANGE, @[ipoMultitonKey], "
                Changed Log Level to: #{LogMessage.LEVELS[logLevel]}
              "
              @[ipoJunction].sendMessage STDLOG, changedLevelMessage
              break
            else
              @super note
          return


      @initializeMixin()
