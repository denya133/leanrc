

module.exports = (Module) ->
  class HtmlRenderer extends Module::Renderer
    @inheritProtected()

    @module Module

    @public render: Function,
      default: (aoData, aoOptions) ->
        vhData = Module::Utils.extend {}, aoData ? {}
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

  HtmlRenderer.initialize()
