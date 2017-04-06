RC = require 'RC'
LeanRC = require.main.require 'lib'

module.exports = (Namespace) ->
  class Namespace::HtmlRenderer extends LeanRC::Renderer
    @inheritProtected()
    @public render: Function,
      default: (aoData, aoOptions) ->
        vhData = RC::Utils.extend {}, aoData ? {}
        "
        <html>
          <head>
            <title>#{vhData.title ? ''}</title>
          </head>
          <body>
            <h1>#{vhData.headline1 ? vhData.title ? ''}</h1>
            <p>#{vhData.paragraph ? vhData.description ? ''}</p>
          </body>
        </html>
        "
  Namespace::HtmlRenderer.initialize()
