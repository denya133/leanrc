

module.exports = (Module) ->
  {
    AnyT, NilT
    FuncG, ListG, MaybeG
  } = Module::
  {
    PipeMessage
  } = Module::Pipes::

  class LogMessage extends PipeMessage
    @inheritProtected()
    @module Module

    @public @static DEBUG: Number,
      default: 5
    @public @static INFO: Number,
      default: 4
    @public @static WARN: Number,
      default: 3
    @public @static ERROR: Number,
      default: 2
    @public @static FATAL: Number,
      default: 1
    @public @static NONE: Number,
      default: 0
    @public @static CHANGE: Number,
      default: -1

    @public @static LEVELS: ListG(String),
      default: [ 'NONE', 'FATAL', 'ERROR', 'WARN', 'INFO', 'DEBUG' ]
    @public @static SEND_TO_LOG: String,
      get: ->
        PipeMessage.BASE + 'LoggerModule/sendToLog'
    @public @static STDLOG: String,
      default: 'standardLog'

    @public logLevel: Number,
      get: -> @getHeader().logLevel
      set: (logLevel)->
        header = @getHeader()
        header.logLevel = logLevel
        @setHeader header
        logLevel

    @public sender: String,
      get: -> @getHeader().sender
      set: (sender)->
        header = @getHeader()
        header.sender = sender
        @setHeader header
        sender

    @public time: String,
      get: -> @getHeader().time
      set: (time)->
        header = @getHeader()
        header.time = time
        @setHeader header
        time

    @public message: MaybeG(AnyT),
      get: -> @getBody()

    @public init: FuncG([Number, String, AnyT], NilT),
      default: (logLevel, sender, message)->
        time = new Date().toISOString()
        headers = {logLevel, sender, time}
        @super PipeMessage.NORMAL, headers, message
        return


    @initialize()
