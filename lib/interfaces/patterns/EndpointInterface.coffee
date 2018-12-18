

module.exports = (Module)->
  {
    JoiT, NilT
    FuncG, MaybeG, UnionG
    GatewayInterface
    EndpointInterface: EndpointInterfaceDef
    Interface
  } = Module::

  class EndpointInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual gateway: GatewayInterface

    @virtual tags: MaybeG Array
    @virtual headers: MaybeG Array
    @virtual pathParams: MaybeG Array
    @virtual queryParams: MaybeG Array
    @virtual payload: MaybeG Object
    @virtual responses: MaybeG Array
    @virtual errors: MaybeG Array
    @virtual title: MaybeG String
    @virtual synopsis: MaybeG String
    @virtual isDeprecated: Boolean

    @virtual tag: FuncG String, EndpointInterfaceDef
    @virtual header: FuncG [String, JoiT, MaybeG String], EndpointInterfaceDef
    @virtual pathParam: FuncG [String, JoiT, MaybeG String], EndpointInterfaceDef
    @virtual queryParam: FuncG [String, JoiT, MaybeG String], EndpointInterfaceDef
    @virtual body: FuncG [JoiT, MaybeG(UnionG Array, String), MaybeG String], EndpointInterfaceDef
    @virtual response: FuncG [UnionG(Number, String, JoiT, NilT), MaybeG(UnionG JoiT, String, Array), MaybeG(UnionG Array, String), MaybeG String], EndpointInterfaceDef
    @virtual error: FuncG [UnionG(Number, String), MaybeG String], EndpointInterfaceDef
    @virtual summary: FuncG String, EndpointInterfaceDef
    @virtual description: FuncG String, EndpointInterfaceDef
    @virtual deprecated: FuncG Boolean, EndpointInterfaceDef


    @initialize()
