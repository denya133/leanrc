

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface (BaseClass) ->
    class ProxyInterface extends BaseClass
      @inheritProtected()
      @include Module::NotifierInterface

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


    ProxyInterface.initializeInterface()
