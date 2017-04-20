

module.exports = (Module)->
  {ANY, NILL} = Module::

  class ProxyInterface extends Module::Interface
    @inheritProtected()
    @include Module::NotifierInterface

    @module Module

    @public @virtual getProxyName: Function,
      args: []
      return: String
    @public @virtual setData: Function,
      args: [ANY]
      return: NILL
    @public @virtual getData: Function,
      args: []
      return: ANY
    @public @virtual onRegister: Function,
      args: []
      return: NILL
    @public @virtual onRemove: Function,
      args: []
      return: NILL


  ProxyInterface.initialize()
