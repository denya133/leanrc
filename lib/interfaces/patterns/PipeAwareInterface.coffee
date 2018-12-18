

module.exports = (Module)->
  {
    FuncG
    PipeFittingInterface
    Interface
  } = Module::

  class PipeAwareInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual acceptInputPipe: FuncG [String, PipeFittingInterface]
    @virtual acceptOutputPipe: FuncG [String, PipeFittingInterface]


    @initialize()
