

module.exports = (Module)->
  {
    NilT
    FuncG
    ProxyInterface
    Interface
  } = Module::

  class ModelInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual registerProxy: FuncG ProxyInterface, NilT
    @virtual removeProxy: FuncG String, ProxyInterface
    @virtual retrieveProxy: FuncG String, ProxyInterface
    @virtual hasProxy: FuncG String, Boolean


    @initialize()
