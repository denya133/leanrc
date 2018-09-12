

module.exports = (Module) ->
  {
    PipeMessageInterface
    FilterControlMessage
  } = Module::Pipes::

  class LogFilterMessage extends FilterControlMessage
    @inheritProtected()
    @module Module

    @public @static BASE: String,
      get: -> "#{FilterControlMessage.BASE}LoggerModule/"
    @public @static LOG_FILTER_NAME: String,
      get: -> "#{@BASE}logFilter/"
    @public @static SET_LOG_LEVEL: String,
      get: -> "#{@BASE}setLogLevel/"

    @public logLevel: Number

    @public @static filterLogByLevel: Function,
      args: [PipeMessageInterface, Object]
      return: Module::NILL
      default: (message, params)->
        if message.getHeader().logLevel > params.logLevel
          throw new Error()

    @public init: Function,
      default: (action, logLevel = 0)->
        @super action, @constructor.LOG_FILTER_NAME, null, {logLevel}
        @logLevel = logLevel
        return


    @initialize()
