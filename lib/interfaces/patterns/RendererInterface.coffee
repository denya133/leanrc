

module.exports = (Module)->
  {
    AnyT
    FuncG, MaybeG, InterfaceG
    ContextInterface, ResourceInterface
    ProxyInterface
  } = Module::

  class RendererInterface extends ProxyInterface
    @inheritProtected()
    @module Module

    @virtual @async render: FuncG [ContextInterface, AnyT, ResourceInterface, MaybeG InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: String
      entityName: String
      recordName: String
    }], MaybeG AnyT


    @initialize()
