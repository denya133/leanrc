RC            = require 'RC'
{ANY, NILL} = RC::


module.exports = (LeanRC)->
  class LeanRC::EndpointInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual gateway: LeanRC::GatewayInterface

    @public @virtual tags: Array
    @public @virtual headers: Array
    @public @virtual pathParams: Array
    @public @virtual queryParams: Array
    @public @virtual payload: Object
    @public @virtual responses: Array
    @public @virtual errors: Array
    @public @virtual title: String
    @public @virtual synopsis: String
    @public @virtual isDeprecated: Boolean

    @public @virtual tag: Function,
      args: [String]
      return: LeanRC::EndpointInterface

    @public @virtual header: Function,
      args: [String, Object, [String, NILL]]
      return: LeanRC::EndpointInterface

    @public @virtual pathParam: Function,
      args: [String, Object, [String, NILL]]
      return: LeanRC::EndpointInterface

    @public @virtual queryParam: Function,
      args: [String, Object, [String, NILL]]
      return: LeanRC::EndpointInterface

    @public @virtual body: Function,
      args: [Object, [Array, NILL], [String, NILL]]
      return: LeanRC::EndpointInterface

    @public @virtual response: Function,
      args: [[Number, String], [Object, NILL], [Array, NILL], [String, NILL]]
      return: LeanRC::EndpointInterface

    @public @virtual error: Function,
      args: [[Number, String], String]
      return: LeanRC::EndpointInterface

    @public @virtual summary: Function,
      args: [String]
      return: LeanRC::EndpointInterface

    @public @virtual description: Function,
      args: [String]
      return: LeanRC::EndpointInterface

    @public @virtual deprecated: Function,
      args: [Boolean]
      return: LeanRC::EndpointInterface


  return LeanRC::EndpointInterface.initialize()
