

module.exports = (Module)->
  {
    JoiT
    FuncG, MaybeG, UnionG
    GatewayInterface
    EndpointInterface: EndpointInterfaceDef
    Interface
  } = Module::

  class EndpointInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual gateway: GatewayInterface

    @virtual tags: Array
    @virtual headers: Array
    @virtual pathParams: Array
    @virtual queryParams: Array
    @virtual payload: Object
    @virtual responses: Array
    @virtual errors: Array
    @virtual title: String
    @virtual synopsis: String
    @virtual isDeprecated: Boolean

    @virtual tag: FuncG String, EndpointInterfaceDef
    @virtual header: FuncG [String, Object, MaybeG String], EndpointInterfaceDef
    @virtual pathParam: FuncG [String, Object, MaybeG String], EndpointInterfaceDef
    @virtual queryParam: FuncG [String, Object, MaybeG String], EndpointInterfaceDef
    @virtual body: FuncG [Object, MaybeG(Array), MaybeG String], EndpointInterfaceDef
    @virtual response: FuncG [UnionG(Number, String), MaybeG(JoiT), MaybeG(Array), MaybeG String], EndpointInterfaceDef
    @virtual error: FuncG [UnionG(Number, String), String], EndpointInterfaceDef
    @virtual summary: FuncG String, EndpointInterfaceDef
    @virtual description: FuncG String, EndpointInterfaceDef
    @virtual deprecated: FuncG Boolean, EndpointInterfaceDef


    @initialize()
