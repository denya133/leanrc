

module.exports = (Module)->
  class QueueControlMessage extends Module::PipeMessage
    @inheritProtected()

    @Module: Module

    @public @static BASE: String,
      get: -> "#{Module::PipeMessage.BASE}queue/"
    @public @static FLUSH: String,
      get: -> "#{@BASE}flush"
    @public @static SORT: String,
      get: -> "#{@BASE}sort"
    @public @static FIFO: String,
      get: -> "#{@BASE}fifo"

    @public init: Function,
      default: (asType)->
        @super asType


  QueueControlMessage.initialize()
