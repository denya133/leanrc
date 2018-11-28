

module.exports = (Module)->
  {
    NilT
    FuncG, UnionG, MaybeG
    SwitchInterface
    Interface
  } = Module::

  class RequestInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual req: Object
    @virtual switch: SwitchInterface

    # @virtual header: Object
    # @virtual headers: Object
    # @virtual method: String
    # @virtual url: String
    # @virtual originalUrl: String
    # @virtual origin: String
    # @virtual href: String
    # @virtual path: String
    # @virtual query: Object
    # @virtual querystring: String
    # @virtual host: String
    # @virtual hostname: String
    # @virtual fresh: Boolean
    # @virtual stale: Boolean
    # @virtual idempotent: Boolean
    # @virtual socket: MaybeG Object
    # @virtual charset: String
    # @virtual length: Number
    # @virtual protocol: String
    # @virtual secure: Boolean
    # @virtual ip: String
    # @virtual ips: Array
    # @virtual subdomains: Array
    @virtual is: FuncG [UnionG String, Array], UnionG String, Boolean, NilT
    @virtual accepts: FuncG [MaybeG UnionG String, Array], UnionG String, Array, Boolean
    @virtual acceptsEncodings: FuncG [MaybeG UnionG String, Array], UnionG String, Array
    @virtual acceptsCharsets: FuncG [MaybeG UnionG String, Array], UnionG String, Array
    @virtual acceptsLanguages: FuncG [MaybeG UnionG String, Array], UnionG String, Array
    # @virtual type: String
    @virtual get: FuncG String, String
    # # @virtual toJSON: FuncG [], Object
    # # @virtual inspect: FuncG [], Object


    @initialize()
