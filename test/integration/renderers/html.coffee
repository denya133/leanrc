

module.exports = (Module) ->
  {
    AnyT
    FuncG, MaybeG, InterfaceG
    ContextInterface, ResourceInterface
    Renderer
    Utils: { assign }
  } = Module::

  class HtmlRenderer extends Renderer
    @inheritProtected()
    @module Module

    @public @async render: FuncG([ContextInterface, AnyT, ResourceInterface, MaybeG InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: String
      entityName: String
      recordName: String
    }], MaybeG AnyT),
      default: (ctx, aoData, resource, aoOptions) ->
        vhData = assign {}, aoData ? {}
        yield return "
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

    @initialize()
