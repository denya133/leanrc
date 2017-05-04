Logger = require '../../logger'
{
  LogMessage
  LogFilterMessage
} = Logger::

module.exports = (Module) ->
  {
    Pipes
  } = Module::
  {
    JunctionMediator
    Junction
    PipeAwareModule
    TeeMerge
    Filter
    PipeListener
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

  class CoreJunctionMediator extends JunctionMediator
    @inheritProtected()
    @module Module

    ipoMultitonKey = Symbol.for '~multitonKey'

    @public @static NAME: String,
      default: 'TomatosCoreJunctionMediator'

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

    @public handlePipeMessage: Function,
      default: (aoMessage)->
        # ... some code
        return

    @public init: Function,
      default: ->
        @super CoreJunctionMediator.NAME, Junction.new()


  CoreJunctionMediator.initialize()
