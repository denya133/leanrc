

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG
    NotifierInterface
  } = Module::

  class ProxyInterface extends NotifierInterface
    @inheritProtected()
    @module Module

    @virtual getProxyName: FuncG [], String
    @virtual setData: FuncG AnyT, NilT
    @virtual getData: FuncG [], AnyT
    @virtual onRegister: Function
    @virtual onRemove: Function


    @initialize()
