

module.exports = (Module)->
  class PipeListener extends Module::CoreObject
    @inheritProtected()
    @implements Module::PipeFittingInterface

    @module Module

    ipoContext = @private context: Object
    ipmListener = @private listener: Module::LAMBDA

    @public connect: Function,
      default: ->
        return no

    @public disconnect: Function,
      default: ->
        return null

    @public write: Function,
      default: (aoMessage)->
        @[ipmListener].apply @[ipoContext], [aoMessage]
        return yes

    @public init: Function,
      default: (aoContext, amListener)->
        @super arguments...
        @[ipoContext] = aoContext
        @[ipmListener] = amListener


  PipeListener.initialize()
