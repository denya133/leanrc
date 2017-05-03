

module.exports = (Module)->
  class TeeSplit extends Module::CoreObject
    @inheritProtected()
    @implements Module::PipeFittingInterface
    @module Module

    iplOutputs = @protected outputs: Array

    @public connect: Function,
      default: (aoOutput)->
        @[iplOutputs] ?= []
        @[iplOutputs].push aoOutput
        return yes

    @public disconnect: Function,
      default: ->
        @[iplOutputs] ?= []
        return @[iplOutputs].pop()

    @public disconnectFitting: Function,
      args: [Module::PipeFittingInterface]
      return: Module::PipeFittingInterface
      default: (aoTarget)->
        voRemoved = null
        @[iplOutputs] ?= []
        for aoOutput, i in @[iplOutputs]
          if aoOutput is aoTarget
            @[iplOutputs][i..i] = []
            voRemoved = aoOutput
            break
        voRemoved

    @public write: Function,
      default: (aoMessage)->
        vbSuccess = yes
        @[iplOutputs].forEach (aoOutput)->
          unless aoOutput.write aoMessage
            vbSuccess = no
        vbSuccess

    @public init: Function,
      default: (output1=null, output2=null)->
        @super arguments...
        if output1?
          @connect output1
        if output2?
          @connect output2


  TeeSplit.initialize()
