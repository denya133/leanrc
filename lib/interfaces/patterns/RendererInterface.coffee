

module.exports = (Module)->
  Module.defineInterface 'RendererInterface', (BaseClass) ->
    class RendererInterface extends BaseClass
      @inheritProtected()
      @include Module::ProxyInterface

      @module Module

      @public @async @virtual render: Function,
        args: [Object, Object]
        return: Module::ANY


    RendererInterface.initializeInterface()
