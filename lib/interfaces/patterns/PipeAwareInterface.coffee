RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::PipeAwareInterface extends RC::Interface
    @inheritProtected()
    @Module: LeanRC

    @public @virtual acceptInputPipe: Function,
      args: [String, LeanRC::PipeFittingInterface]
      return: RC::Constants.NILL
    @public @virtual acceptOutputPipe: Function,
      args: [String, LeanRC::PipeFittingInterface]
      return: RC::Constants.NILL


  return LeanRC::PipeAwareInterface.initialize()
