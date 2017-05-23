

module.exports = (Module)->
  {
    ANY

    CoreObject
    RequestInterface
  } = Module::

  class Request extends CoreObject
    @inheritProtected()
    @implements RequestInterface
    @module Module

    ipoReq = @protected req: Object
    @public baseUrl: String
    @public body: ANY
    @public database: String
    @public headers: Object
    @public hostname: String
    @public method: String
    @public originalUrl: String
    @public path: String
    @public pathParams: Object
    @public port: Number
    @public protocol: String
    @public queryParams: Object
    @public rawBody: Buffer
    @public secure: Boolean
    @public url: String
    @public xhr: Boolean

    @public accepts: Function,
      default: (name)->
    @public acceptsCharsets: Function,
      default: (name)->
    @public acceptsEncodings: Function,
      default: (name)->
    @public acceptsLanguages: Function,
      default: (name)->

    @public getHeader: Function,
      default: (name)->

    @public get: Function,
      default: (args...)-> @getHeader args...

    @public cookie: Function,
      default: (name, options)->

    @public 'is': Function,
      default: (types)->

    @public init: Function,
      default: (req)->
        @super()
        @[ipoReq] = req
        return


  Request.initialize()
