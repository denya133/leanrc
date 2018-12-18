

module.exports = (Module)->
  {
    AnyT
    FuncG, MaybeG
    NotifierInterface
  } = Module::

  class ProxyInterface extends NotifierInterface
    @inheritProtected()
    @module Module

    @virtual getProxyName: FuncG [], String
    @virtual setData: FuncG AnyT
    @virtual getData: FuncG [], MaybeG AnyT
    @virtual onRegister: Function
    @virtual onRemove: Function


    @initialize()
