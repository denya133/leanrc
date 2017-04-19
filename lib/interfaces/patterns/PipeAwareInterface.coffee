

module.exports = (Module)->
  {ANY, NILL} = Module::

  class PipeAwareInterface extends Module::Interface
    @inheritProtected()
    @Module: Module

    @public @virtual acceptInputPipe: Function,
      args: [String, Module::PipeFittingInterface]
      return: NILL
    @public @virtual acceptOutputPipe: Function,
      args: [String, Module::PipeFittingInterface]
      return: NILL


  PipeAwareInterface.initialize()
