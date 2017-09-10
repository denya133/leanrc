

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface (BaseClass) ->
    class EndpointInterface extends BaseClass
      @inheritProtected()

      @public @virtual gateway: Module::ProxyInterface

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
        return: Module::EndpointInterface

      @public @virtual header: Function,
        args: [String, Object, [String, NILL]]
        return: Module::EndpointInterface

      @public @virtual pathParam: Function,
        args: [String, Object, [String, NILL]]
        return: Module::EndpointInterface

      @public @virtual queryParam: Function,
        args: [String, Object, [String, NILL]]
        return: Module::EndpointInterface

      @public @virtual body: Function,
        args: [Object, [Array, NILL], [String, NILL]]
        return: Module::EndpointInterface

      @public @virtual response: Function,
        args: [[Number, String], [Object, NILL], [Array, NILL], [String, NILL]]
        return: Module::EndpointInterface

      @public @virtual error: Function,
        args: [[Number, String], String]
        return: Module::EndpointInterface

      @public @virtual summary: Function,
        args: [String]
        return: Module::EndpointInterface

      @public @virtual description: Function,
        args: [String]
        return: Module::EndpointInterface

      @public @virtual deprecated: Function,
        args: [Boolean]
        return: Module::EndpointInterface


    EndpointInterface.initializeInterface()
