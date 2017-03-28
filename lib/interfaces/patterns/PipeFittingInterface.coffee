RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::PipeFittingInterface extends RC::Interface
    @inheritProtected()
    @Module: LeanRC

    @public @virtual connect: Function,
      args: [LeanRC::PipeFittingInterface]
      return: Boolean
    @public @virtual disconnect: Function,
      args: []
      return: LeanRC::PipeFittingInterface
    @public @virtual write: Function,
      args: [LeanRC::PipeMessageInterface]
      return: Boolean


  return LeanRC::PipeFittingInterface.initialize()
