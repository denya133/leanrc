{ Builder } = require 'xml2js'


module.exports = (Module) ->
  class XmlRenderer extends Module::Renderer
    @inheritProtected()

    @module Module

    @public render: Function,
      default: (aoData, aoOptions) ->
        vhData = Module::Utils.extend {}, aoData ? {}
        builder = new Builder()
        builder.buildObject vhData

  XmlRenderer.initialize()
