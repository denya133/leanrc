

module.exports = (Module)->
  {
    FuncG, MaybeG
    PipeMessage
  } = Module::

  class LineControlMessage extends PipeMessage
    @inheritProtected()

    @module Module

    @public @static BASE: String,
      get: -> "#{PipeMessage.BASE}queue/"
    @public @static FLUSH: String,
      get: -> "#{@BASE}flush"
    @public @static SORT: String,
      get: -> "#{@BASE}sort"
    @public @static FIFO: String,
      get: -> "#{@BASE}fifo"

    @public init: FuncG([
      String, MaybeG(Object), MaybeG(Object), MaybeG Number
    ]),
      default: (asType)->
        @super asType
        return


    @initialize()
