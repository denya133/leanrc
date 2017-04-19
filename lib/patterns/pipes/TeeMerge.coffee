

module.exports = (Module)->
  class TeeMerge extends Module::Pipe
    @inheritProtected()

    @Module: Module

    @public connectInput: Function,
      args: [Module::PipeFittingInterface]
      return: Boolean
      default: (aoInput)->
        aoInput.connect @

    constructor: (input1=null, input2=null)->
      super arguments...
      if input1?
        @connectInput input1
      if input2?
        @connectInput input2


  TeeMerge.initialize()
