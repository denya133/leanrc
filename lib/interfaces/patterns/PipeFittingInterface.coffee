

module.exports = (Module)->
  Module.defineInterface 'PipeFittingInterface', (BaseClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @virtual connect: Function,
        args: [Module::PipeFittingInterface]
        return: Boolean
      @public @virtual disconnect: Function,
        args: []
        return: Module::PipeFittingInterface
      @public @virtual write: Function,
        args: [Module::PipeMessageInterface]
        return: Boolean


      @initializeInterface()
