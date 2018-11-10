

module.exports = (Module)->
  {
    NilT
    FuncG
    PipeFittingInterface
    Interface
  } = Module::

  class PipeAwareInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual acceptInputPipe: FuncG [String, PipeFittingInterface], NilT
    @virtual acceptOutputPipe: FuncG [String, PipeFittingInterface], NilT


    @initialize()
