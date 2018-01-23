

module.exports = (Module)->
  Module.defineInterface 'RendererInterface', (BaseClass) ->
    class extends BaseClass
      @inheritProtected()
      @include Module::ProxyInterface

      @public @async @virtual render: Function,
        args: [Object, Object]
        return: Module::ANY


      @initializeInterface()
