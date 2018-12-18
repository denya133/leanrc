

module.exports = (Module)->
  {
    LambdaT, PointerT
    FuncG, MaybeG
    PipeFittingInterface, PipeMessageInterface
    CoreObject
  } = Module::

  class PipeListener extends CoreObject
    @inheritProtected()
    @implements PipeFittingInterface
    @module Module

    ipoContext = PointerT @private context: Object
    ipmListener = PointerT @private listener: LambdaT

    @public connect: FuncG(PipeFittingInterface, Boolean),
      default: ->
        return no

    @public disconnect: FuncG([], MaybeG PipeFittingInterface),
      default: ->
        return null

    @public write: FuncG(PipeMessageInterface, Boolean),
      default: (aoMessage)->
        @[ipmListener].call @[ipoContext], aoMessage
        return yes

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: FuncG([Object, Function]),
      default: (aoContext, amListener)->
        @super arguments...
        @[ipoContext] = aoContext
        @[ipmListener] = amListener
        return


    @initialize()
