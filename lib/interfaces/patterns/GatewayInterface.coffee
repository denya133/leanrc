

module.exports = (Module)->
  {
    JoiT
    FuncG, MaybeG, SubsetG
    EndpointInterface
    ProxyInterface
  } = Module::

  class GatewayInterface extends ProxyInterface
    @inheritProtected()
    @module Module

    @virtual tryLoadEndpoint: FuncG String, MaybeG SubsetG EndpointInterface
    @virtual getEndpointByName: FuncG String, MaybeG SubsetG EndpointInterface
    @virtual getEndpointName: FuncG [String, String], String
    @virtual getStandardActionEndpoint: FuncG [String, String], SubsetG EndpointInterface
    @virtual getEndpoint: FuncG [String, String], SubsetG EndpointInterface
    @virtual swaggerDefinitionFor: FuncG [String, String, MaybeG Object], EndpointInterface
    @virtual getSchema: FuncG String, JoiT


    @initialize()
