RC = require 'RC'
{ANY, NILL} = RC::


module.exports = (LeanRC)->
  class LeanRC::PipeAwareInterface extends RC::Interface
    @inheritProtected()
    @Module: LeanRC

    @public @virtual acceptInputPipe: Function,
      args: [String, LeanRC::PipeFittingInterface]
      return: NILL
    @public @virtual acceptOutputPipe: Function,
      args: [String, LeanRC::PipeFittingInterface]
      return: NILL


  return LeanRC::PipeAwareInterface.initialize()
