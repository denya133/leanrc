

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface 'PipeAwareInterface', (BaseClass) ->
    class PipeAwareInterface extends BaseClass
      @inheritProtected()

      @public @virtual acceptInputPipe: Function,
        args: [String, Module::PipeFittingInterface]
        return: NILL
      @public @virtual acceptOutputPipe: Function,
        args: [String, Module::PipeFittingInterface]
        return: NILL


    PipeAwareInterface.initializeInterface()
