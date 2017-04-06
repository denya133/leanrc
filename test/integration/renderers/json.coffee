RC = require 'RC'
LeanRC = require.main.require 'lib'

module.exports = (Namespace) ->
  class Namespace::JsonRenderer extends LeanRC::Renderer
    @inheritProtected()
    @public render: Function,
      default: (aoData, aoOptions) ->
        vhData = RC::Utils.extend {}, aoData
        JSON.stringify vhData ? null
  Namespace::JsonRenderer.initialize()
