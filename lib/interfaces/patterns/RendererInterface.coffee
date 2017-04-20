

module.exports = (Module)->
  class RendererInterface extends Module::Interface
    @inheritProtected()
    @include Module::ProxyInterface

    @module Module

    @public @virtual render: Function,
      args: [Object, Object]
      return: Module::ANY


  RendererInterface.initialize()
