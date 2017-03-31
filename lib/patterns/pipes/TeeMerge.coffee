RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::TeeMerge extends LeanRC::Pipe
    @inheritProtected()

    @Module: LeanRC

    @public connectInput: Function,
      args: [LeanRC::PipeFittingInterface]
      return: Boolean
      default: (aoInput)->
        aoInput.connect @

    constructor: (input1=null, input2=null)->
      super arguments...
      if input1?
        @connectInput input1
      if input2?
        @connectInput input2


  return LeanRC::TeeMerge.initialize()
