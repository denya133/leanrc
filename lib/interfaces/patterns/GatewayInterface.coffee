RC            = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::GatewayInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual swaggerDefinition: Function,
      args: [String, Function]
      return: RC::NILL

    @public @virtual swaggerDefinitionFor: Function,
      args: [String]
      return: LeanRC::EndpointInterface


  return LeanRC::GatewayInterface.initialize()
