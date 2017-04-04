RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Pipe extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::PipeFittingInterface

    @Module: LeanRC

    ipoOutput = @protected output: LeanRC::PipeFittingInterface

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

    constructor: (aoOutput)->
      super arguments...
      if aoOutput?
        @connect aoOutput


  return LeanRC::Pipe.initialize()
