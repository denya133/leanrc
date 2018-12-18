

module.exports = (Module)->
  {
    FuncG, MaybeG
    PipeMessageInterface
    PipeFittingInterface: PipeFittingInterfaceDef
    Interface
  } = Module::

  class PipeFittingInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual connect: FuncG PipeFittingInterfaceDef, Boolean
    @virtual disconnect: FuncG [], MaybeG PipeFittingInterfaceDef
    @virtual write: FuncG PipeMessageInterface, Boolean


    @initialize()
