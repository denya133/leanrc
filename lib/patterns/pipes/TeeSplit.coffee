

module.exports = (Module)->
  {
    NilT, PointerT
    FuncG, ListG, MaybeG
    PipeFittingInterface, PipeMessageInterface
    CoreObject
  } = Module::

  class TeeSplit extends CoreObject
    @inheritProtected()
    @implements PipeFittingInterface
    @module Module

    iplOutputs = PointerT @protected outputs: MaybeG ListG PipeFittingInterface

    @public connect: FuncG(PipeFittingInterface, Boolean),
      default: (aoOutput)->
        @[iplOutputs] ?= []
        @[iplOutputs].push aoOutput
        return yes

    @public disconnect: FuncG([], MaybeG PipeFittingInterface),
      default: ->
        @[iplOutputs] ?= []
        return @[iplOutputs].pop()

    @public disconnectFitting: FuncG(
      PipeFittingInterface, PipeFittingInterface
    ),
      default: (aoTarget)->
        voRemoved = null
        @[iplOutputs] ?= []
        for aoOutput, i in @[iplOutputs]
          if aoOutput is aoTarget
            @[iplOutputs][i..i] = []
            voRemoved = aoOutput
            break
        voRemoved

    @public write: FuncG(PipeMessageInterface, Boolean),
      default: (aoMessage)->
        vbSuccess = yes
        @[iplOutputs].forEach (aoOutput)->
          unless aoOutput.write aoMessage
            vbSuccess = no
        vbSuccess

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: FuncG([
      MaybeG(PipeFittingInterface), MaybeG PipeFittingInterface
    ], NilT),
      default: (output1=null, output2=null)->
        @super arguments...
        if output1?
          @connect output1
        if output2?
          @connect output2
        return


    @initialize()
