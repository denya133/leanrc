

module.exports = (Module)->
  Module.defineInterface 'GatewayInterface', (BaseClass) ->
    class GatewayInterface extends BaseClass
      @inheritProtected()

      @module Module

      @public @virtual swaggerDefinition: Function,
        args: [String, Function]
        return: Module::NILL

      @public @virtual swaggerDefinitionFor: Function,
        args: [String]
        return: Module::EndpointInterface


    GatewayInterface.initializeInterface()
