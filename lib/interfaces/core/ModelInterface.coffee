

module.exports = (Module)->
  {NILL} = Module::

  Module.defineInterface 'ModelInterface', (BaseClass) ->
    class ModelInterface extends BaseClass
      @inheritProtected()
      @module Module

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



    ModelInterface.initializeInterface()
