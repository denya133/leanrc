

module.exports = (Module)->
  {
    NilT
    FuncG, MaybeG
    ProxyInterface
    Interface
  } = Module::

  class ModelInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual registerProxy: FuncG ProxyInterface, NilT
    @virtual removeProxy: FuncG String, MaybeG ProxyInterface
    @virtual retrieveProxy: FuncG String, MaybeG ProxyInterface
    @virtual hasProxy: FuncG String, Boolean


    @initialize()
