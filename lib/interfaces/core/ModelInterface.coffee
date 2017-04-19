

module.exports = (Module)->
  {NILL} = Module::

  class ModelInterface extends Module::Interface
    @inheritProtected()
    @Module: Module

    @public @virtual registerProxy: Function,
      args: [Module::ProxyInterface]
      return: NILL
    @public @virtual removeProxy: Function,
      args: [String]
      return: Module::ProxyInterface
    @public @virtual retrieveProxy: Function,
      args: [String]
      return: Module::ProxyInterface
    @public @virtual hasProxy: Function,
      args: [String]
      return: Boolean



  ModelInterface.initialize()
