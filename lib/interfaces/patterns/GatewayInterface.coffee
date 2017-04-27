

module.exports = (Module)->
  Module.defineInterface (BaseClass) ->
    class GatewayInterface extends BaseClass
      @inheritProtected()

      @public @virtual swaggerDefinition: Function,
        args: [String, Function]
        return: Module::NILL

      @public @virtual swaggerDefinitionFor: Function,
        args: [String]
        return: Module::EndpointInterface


    GatewayInterface.initializeInterface()
