

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, ListG, MaybeG, InterfaceG, StructG
    ContextInterface, MediatorInterface, RendererInterface, ResourceInterface
    SwitchInterface: SwitchInterfaceDef
  } = Module::

  class SwitchInterface extends MediatorInterface
    @inheritProtected()
    @module Module

    @virtual routerName: String

    @virtual responseFormats: ListG String

    @virtual jsonRendererName: String
    @virtual htmlRendererName: String
    @virtual xmlRendererName: String
    @virtual atomRendererName: String

    @virtual use: FuncG [Number, Function], SwitchInterfaceDef

    @virtual @async handleStatistics: FuncG [Number, Number, Number, ContextInterface], NilT

    @virtual rendererFor: FuncG String, RendererInterface

    @virtual @async sendHttpResponse: FuncG [ContextInterface, MaybeG(AnyT), ResourceInterface, InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: String
      entityName: String
      recordName: String
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
      keyName: String
      entityName: String
      recordName: String
    }], NilT

    @virtual createNativeRoute: FuncG [InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: String
      entityName: String
      recordName: String
    }], NilT


    @initialize()
