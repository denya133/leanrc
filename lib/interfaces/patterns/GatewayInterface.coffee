

module.exports = (Module)->
  class GatewayInterface extends Module::Interface
    @inheritProtected()

    @Module: Module

    @public @virtual swaggerDefinition: Function,
      args: [String, Function]
      return: Module::NILL

    @public @virtual swaggerDefinitionFor: Function,
      args: [String]
      return: Module::EndpointInterface


  GatewayInterface.initialize()
