

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, UnionG, MaybeG
    RequestInterface, ResponseInterface, SwitchInterface, CookiesInterface
    Interface
  } = Module::

  class ContextInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual req: Object
    @virtual res: Object
    @virtual request: RequestInterface
    @virtual response: ResponseInterface
    @virtual state: Object
    @virtual switch: SwitchInterface
    @virtual respond: Boolean
    @virtual routePath: String
    @virtual pathParams: Object

    @virtual throw: FuncG [UnionG(String, Number), MaybeG(String), MaybeG Object], NilT

    @virtual assert: FuncG [AnyT, UnionG(String, Number), MaybeG(String), MaybeG Object], NilT

    @virtual onerror: FuncG Error, NilT

    # Request aliases
    @virtual header: Object
    @virtual headers: Object
    @virtual method: String
    @virtual url: String
    @virtual originalUrl: String
    @virtual origin: String
    @virtual href: String
    @virtual path: String
    @virtual query: Object
    @virtual querystring: String
    @virtual host: String
    @virtual hostname: String
    @virtual fresh: Boolean
    @virtual stale: Boolean
    @virtual socket: Object
    @virtual protocol: String
    @virtual secure: Boolean
    @virtual ip: String
    @virtual ips: Array
    @virtual subdomains: Array
    @virtual is: FuncG [UnionG String, Array], UnionG String, Boolean, NilT
    @virtual accepts: FuncG [UnionG String, Array], UnionG String, Array, Boolean
    @virtual acceptsEncodings: FuncG [UnionG String, Array], UnionG String, Array
    @virtual acceptsCharsets: FuncG [UnionG String, Array], UnionG String, Array
    @virtual acceptsLanguages: FuncG [UnionG String, Array], UnionG String, Array
    @virtual get: FuncG String, String

    # Response aliases
    @virtual body: UnionG String, Buffer, Object, Array, Number, Boolean
    @virtual status: UnionG String, Number
    @virtual message: String
    @virtual length: Number
    @virtual type: String
    @virtual headerSent: Boolean
    @virtual redirect: FuncG [String, String], NilT
    @virtual attachment: FuncG String, NilT
    @virtual set: FuncG [UnionG(String, Object, Array), String], NilT
    @virtual append: FuncG [String, UnionG String, Array], UnionG String, Array
    @virtual vary: FuncG String, NilT
    @virtual flushHeaders: Function
    @virtual remove: FuncG String, NilT
    @virtual lastModified: Date
    @virtual etag: String

    # @virtual toJSON: FuncG [], Object
    #
    # @virtual inspect: FuncG [], Object


    @initialize()
