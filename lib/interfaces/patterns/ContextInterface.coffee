

module.exports = (Module)->
  {
    ANY
    NILL

    RequestInterface
    ResponseInterface
    SwitchInterface
  } = Module::

  Module.defineInterface 'ContextInterface', (BaseClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @virtual req: Object
      @public @virtual res: Object
      @public @virtual request: RequestInterface
      @public @virtual response: ResponseInterface
      @public @virtual state: Object
      @public @virtual switch: SwitchInterface
      @public @virtual respond: Boolean
      @public @virtual routePath: String
      @public @virtual pathParams: Object

      @public @virtual throw: Function,
        args: [[String, Number], [String, NILL], [Object, NILL]]
        return: NILL

      @public @virtual assert: Function,
        args: [ANY, [String, Number], [String, NILL], [Object, NILL]]
        return: NILL

      @public @virtual onerror: Function,
        args: [Error]
        return: NILL

      # Request aliases
      @public @virtual header: Object
      @public @virtual headers: Object
      @public @virtual method: String
      @public @virtual url: String
      @public @virtual originalUrl: String
      @public @virtual origin: String
      @public @virtual href: String
      @public @virtual path: String
      @public @virtual query: Object
      @public @virtual querystring: String
      @public @virtual host: String
      @public @virtual hostname: String
      @public @virtual fresh: Boolean
      @public @virtual stale: Boolean
      @public @virtual socket: Object
      @public @virtual protocol: String
      @public @virtual secure: Boolean
      @public @virtual ip: String
      @public @virtual ips: Array
      @public @virtual subdomains: Array
      @public @virtual is: Function,
        args: [[String, Array]]
        return: [String, Boolean, NILL]
      @public @virtual accepts: Function,
        args: [[String, Array]]
        return: [String, Array, Boolean]
      @public @virtual acceptsEncodings: Function,
        args: [[String, Array]]
        return: [String, Array]
      @public @virtual acceptsCharsets: Function,
        args: [[String, Array]]
        return: [String, Array]
      @public @virtual acceptsLanguages: Function,
        args: [[String, Array]]
        return: [String, Array]
      @public @virtual get: Function,
        args: [String]
        return: String

      # Response aliases
      @public @virtual body: [String, Buffer, Object, Array, Number, Boolean]
      @public @virtual status: [String, Number]
      @public @virtual message: String
      @public @virtual length: Number
      @public @virtual type: String
      @public @virtual headerSent: Boolean
      @public @virtual redirect: Function,
        args: [String, String]
        return: NILL
      @public @virtual attachment: Function,
        args: [String]
        return: NILL
      @public @virtual set: Function,
        args: [[String, Object, Array], String]
        return: NILL
      @public @virtual append: Function,
        args: [String, [String, Array]]
        return: [String, Array]
      @public @virtual remove: Function,
        args: [String]
        return: NILL
      @public @virtual lastModified: Date
      @public @virtual etag: String

      @public @virtual toJSON: Function,
        args: []
        return: Object

      @public @virtual inspect: Function,
        args: []
        return: Object


      @initializeInterface()
