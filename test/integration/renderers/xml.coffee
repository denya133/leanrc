RC = require 'RC'
{ Builder } = require 'xml2js'
LeanRC = require.main.require 'lib'

module.exports = (Namespace) ->
  class Namespace::XmlRenderer extends LeanRC::Renderer
    @inheritProtected()
    @public render: Function,
      default: (aoData, aoOptions) ->
        vhData = RC::Utils.extend {}, aoData ? {}
        builder = new Builder()
        builder.buildObject vhData
  Namespace::XmlRenderer.initialize()
