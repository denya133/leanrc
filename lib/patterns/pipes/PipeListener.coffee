RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::PipeListener extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::PipeFittingInterface

    @Module: LeanRC

    ipoContext = @private _context: Object
    ipmListener = @private _listener: RC::Constants.LAMBDA

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

    constructor: (aoContext, amListener)->
      super arguments...
      @[ipoContext] = aoContext
      @[ipmListener] = amListener


  return LeanRC::PipeListener.initialize()
