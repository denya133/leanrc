

module.exports = (Module)->
  {
    NilT
    FuncG, MaybeG
    PipeFittingInterface
    Pipe
  } = Module::

  class TeeMerge extends Pipe
    @inheritProtected()
    @module Module

    @public connectInput: FuncG(PipeFittingInterface, Boolean),
      default: (aoInput)->
        aoInput.connect @

    @public init: FuncG([
      MaybeG(PipeFittingInterface), MaybeG PipeFittingInterface
    ], NilT),
      default: (input1=null, input2=null)->
        @super arguments...
        if input1?
          @connectInput input1
        if input2?
          @connectInput input2
        return


    @initialize()
