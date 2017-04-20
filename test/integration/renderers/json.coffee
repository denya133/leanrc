

module.exports = (Module) ->
  class JsonRenderer extends Module::Renderer
    @inheritProtected()

    @module Module

    @public render: Function,
      default: (aoData, aoOptions) ->
        vhData = Module::Utils.extend {}, aoData
        JSON.stringify vhData ? null

  JsonRenderer.initialize()
