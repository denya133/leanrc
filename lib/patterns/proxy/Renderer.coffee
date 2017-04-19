

module.exports = (Module)->
  class Renderer extends Module::Proxy
    @inheritProtected()
    @implements Module::RendererInterface

    @Module: Module

    # may be redefine at inheritance
    @public render: Function,
      default: (aoData, aoOptions)->
        JSON.stringify aoData


  Renderer.initialize()
