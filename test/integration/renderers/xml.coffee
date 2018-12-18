{ Builder } = require 'xml2js'


module.exports = (Module) ->
  {
    AnyT
    FuncG, MaybeG, InterfaceG
    ContextInterface, ResourceInterface
    Renderer
    Utils: { assign }
  } = Module::

  class XmlRenderer extends Renderer
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
        builder = new Builder()
        yield return builder.buildObject vhData

    @initialize()
