

module.exports = (Module)->
  class PipeFittingInterface extends Module::Interface
    @inheritProtected()
    @Module: Module

    @public @virtual connect: Function,
      args: [Module::PipeFittingInterface]
      return: Boolean
    @public @virtual disconnect: Function,
      args: []
      return: Module::PipeFittingInterface
    @public @virtual write: Function,
      args: [Module::PipeMessageInterface]
      return: Boolean


  PipeFittingInterface.initialize()
