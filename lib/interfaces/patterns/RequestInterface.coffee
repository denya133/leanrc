

module.exports = (Module)->
  {
    ANY
    NILL

    ApplicationInterface
  } = Module::

  Module.defineInterface (BaseClass) ->
    class RequestInterface extends BaseClass
      @inheritProtected()

      @public @virtual req: Object
      @public @virtual app: ApplicationInterface

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
      @public @virtual port: Number
      @public @virtual hostname: String
      @public @virtual fresh: Boolean
      @public @virtual stale: Boolean
      @public @virtual idempotent: Boolean
      @public @virtual socket: Object
      @public @virtual charset: String
      @public @virtual length: Number
      @public @virtual protocol: String
      @public @virtual xhr: Boolean
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
      @public @virtual type: String
      @public @virtual get: Function,
        args: [String]
        return: String

      @public @virtual toJSON: Function,
        args: []
        return: Object

      @public @virtual inspect: Function,
        args: []
        return: Object


    RequestInterface.initializeInterface()
