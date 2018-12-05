

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, ListG, MaybeG, InterfaceG, StructG, UnionG
    ContextInterface, MediatorInterface, RendererInterface, ResourceInterface
    SwitchInterface: SwitchInterfaceDef
  } = Module::

  class SwitchInterface extends MediatorInterface
    @inheritProtected()
    @module Module

    @virtual routerName: String

    @virtual responseFormats: ListG String

    @virtual use: FuncG [UnionG(Number, Function), MaybeG Function], SwitchInterfaceDef

    @virtual @async handleStatistics: FuncG [Number, Number, Number, ContextInterface], NilT

    @virtual rendererFor: FuncG String, RendererInterface

    @virtual @async sendHttpResponse: FuncG [ContextInterface, MaybeG(AnyT), ResourceInterface, InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: MaybeG String
      entityName: String
      recordName: MaybeG String
    }], NilT

    @virtual defineRoutes: Function

    @virtual sender: FuncG [String, StructG({
      context: ContextInterface
      reverse: String
    }), InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: MaybeG String
      entityName: String
      recordName: MaybeG String
    }], NilT

    @virtual createNativeRoute: FuncG [InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: MaybeG String
      entityName: String
      recordName: MaybeG String
    }], NilT


    @initialize()
