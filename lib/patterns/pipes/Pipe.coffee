

module.exports = (Module)->
  class Pipe extends Module::CoreObject
    @inheritProtected()
    @module Module
    @implements Module::PipeFittingInterface

    ipoOutput = @protected output: Module::PipeFittingInterface

    @public connect: Function,
      default: (aoOutput)->
        vbSuccess = no
        unless @[ipoOutput]?
          @[ipoOutput] = aoOutput
          vbSuccess = yes
        vbSuccess

    @public disconnect: Function,
      default: ->
        disconnectedFitting = @[ipoOutput]
        @[ipoOutput] = null
        disconnectedFitting

    @public write: Function,
      default: (aoMessage)->
        return @[ipoOutput].write aoMessage

    @public init: Function,
      default: (aoOutput)->
        @super arguments...
        if aoOutput?
          @connect aoOutput


  Pipe.initialize()
