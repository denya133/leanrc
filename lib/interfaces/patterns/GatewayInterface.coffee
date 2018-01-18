

module.exports = (Module)->
  Module.defineInterface 'GatewayInterface', (BaseClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @virtual swaggerDefinition: Function,
        args: [String, Function]
        return: Module::NILL

      @public @virtual registerEndpoints: Function,
        args: [Object]
        return: Module::NILL

      @public @virtual swaggerDefinitionFor: Function,
        args: [String]
        return: Module::EndpointInterface


      @initializeInterface()
