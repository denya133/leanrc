

module.exports = (Module)->
  class Pipe extends Module::CoreObject
    @inheritProtected()
    @implements Module::PipeFittingInterface
    @module Module

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

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: Function,
      default: (aoOutput)->
        @super arguments...
        if aoOutput?
          @connect aoOutput


  Pipe.initialize()
