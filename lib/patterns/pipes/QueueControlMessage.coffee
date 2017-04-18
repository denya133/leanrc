RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::QueueControlMessage extends LeanRC::PipeMessage
    @inheritProtected()

    @Module: LeanRC

    @public @static BASE: String,
      get: -> "#{LeanRC::PipeMessage.BASE}queue/"
    @public @static FLUSH: String,
      get: -> "#{@BASE}flush"
    @public @static SORT: String,
      get: -> "#{@BASE}sort"
    @public @static FIFO: String,
      get: -> "#{@BASE}fifo"

    @public init: Function,
      default: (asType)->
        @super asType


  return LeanRC::QueueControlMessage.initialize()
