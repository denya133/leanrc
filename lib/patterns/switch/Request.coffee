# net         = require 'net' # will be used only 'isIP' function
# contentType = require 'content-type'
# stringify   = require('url').format
# parse       = require 'parseurl'
# qs          = require 'querystring'
# typeis      = require 'type-is'
# fresh       = require 'fresh'

###
Идеи взяты из https://github.com/koajs/koa/blob/master/lib/request.js
###


module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, UnionG, MaybeG
    RequestInterface, SwitchInterface, ContextInterface
    CoreObject
    Utils: { _ }
  } = Module::

  class Request extends CoreObject
    @inheritProtected()
    @implements RequestInterface
    @module Module

    @public req: Object, # native request object
      get: -> @ctx.req

    @public switch: SwitchInterface,
      get: -> @ctx.switch

    @public ctx: ContextInterface

    # @public baseUrl: String # под вопросом?
    # @public database: String # возможно это тоже надо получать из метода из отдельного модуля
    # @public pathname: String
    # @public pathParams: Object # вынести в отдельный модуль, который будет подключаться как миксин, а в чейнинге будет вызваться метод, который будет распарсивать парамсы
    # @public cookie: Function,
    #   default: (name, options)->

    @public body: MaybeG AnyT # тело должен предоставлять миксин из отдельного модуля

    @public header: Object,
      get: -> @headers
    @public headers: Object,
      get: -> @req.headers

    @public originalUrl: String,
      get: -> @ctx.originalUrl

    @public url: String,
      get: -> @req.url
      set: (url)-> @req.url = url

    @public origin: String,
      get: -> "#{@protocol}://#{@host}"

    @public href: String,
      get: ->
        return @originalUrl if /^https?:\/\//i.test @originalUrl
        return @origin + @originalUrl

    @public method: String,
      get: -> @req.method
      set: (method)-> @req.method = method

    @public path: String,
      get: ->
        parse = require 'parseurl'
        parse(@req).pathname
      set: (path)->
        parse = require 'parseurl'
        url = parse @req
        return if url.pathname is path
        url.pathname = path
        url.path = null
        stringify = require('url').format
        @url = stringify url

    @public query: Object,
      get: ->
        qs = require 'querystring'
        qs.parse @querystring
      set: (obj)->
        qs = require 'querystring'
        @querystring = qs.stringify obj
        obj

    @public querystring: String,
      get: ->
        return '' unless @req?
        parse = require 'parseurl'
        parse(@req).query ? ''
      set: (str)->
        parse = require 'parseurl'
        url = parse @req
        return if url.search is "?#{str}"
        url.search = str
        url.path = null
        stringify = require('url').format
        @url = stringify url

    @public search: String,
      get: ->
        return '' unless @querystring
        "?#{@querystring}"
      set: (str)-> @querystring = str

    @public host: String,
      get: ->
        {trustProxy} = @ctx.switch.configs
        host = trustProxy and @get 'X-Forwarded-Host'
        host = host or @get 'Host'
        return '' unless host
        host.split(/\s*,\s*/)[0]

    # port отсутствует в интерфейсе koa - возможно лучше его и здесь не делать, чтобы не ломать интерфейс koa
    # @public port: Number,
    #   get: ->
    #     host = @host
    #     port = if host
    #       host.split(':')[1]
    #     unless port
    #       port = if @protocol is 'https'
    #         443
    #       else
    #         80
    #     Number port

    @public hostname: String,
      get: ->
        host = @host
        return '' unless host
        host.split(':')[0]

    @public fresh: Boolean,
      get: ->
        method = @method
        s = @ctx.status
        # GET or HEAD for weak freshness validation only
        if 'GET' isnt method and 'HEAD' isnt method
          return no
        # 2xx or 304 as per rfc2616 14.26
        if (s >= 200 and s < 300) or 304 is s
          fresh = require 'fresh'
          return fresh @headers, @ctx.response.headers
        return no

    @public stale: Boolean,
      get: -> not @fresh

    @public idempotent: Boolean,
      get: ->
        methods = ['GET', 'HEAD', 'PUT', 'DELETE', 'OPTIONS', 'TRACE']
        _.includes methods, @method

    @public socket: MaybeG(Object),
      get: -> @req.socket

    @public charset: String,
      get: ->
        type = @get 'Content-Type'
        return '' unless type?
        try
          contentType = require 'content-type'
          type = contentType.parse type
        catch err
          return ''
        type.parameters.charset ? ''

    @public length: Number,
      get: ->
        if (contentLength = @get 'Content-Length')?
          return 0 if contentLength is ''
          ~~Number contentLength
        else
          0

    @public protocol: String,
      get: ->
        {trustProxy} = @ctx.switch.configs
        if @socket?.encrypted
          return 'https'
        if @req.secure
          return 'https'
        unless trustProxy
          return 'http'
        proto = @get 'X-Forwarded-Proto'
        proto = 'http'  unless proto
        proto.split(/\s*,\s*/)[0]

    # xhr отсутствует в интерфейсе koa - возможно лучше его и здесь не делать, чтобы не ломать интерфейс koa
    # @public xhr: Boolean,
    #   get: ->
    #     'xmlhttprequest' is String(@headers['X-Requested-With']).toLowerCase()

    @public secure: Boolean,
      get: -> @protocol is 'https'

    @public ip: String

    @public ips: Array,
      get: ->
        {trustProxy} = @ctx.switch.configs
        value = @get 'X-Forwarded-For'
        if trustProxy and value
          value.split /\s*,\s*/
        else
          []

    @public subdomains: Array,
      get: ->
        {subdomainOffset:offset} = @ctx.switch.configs
        hostname = @hostname
        net = require 'net'
        return []  if net.isIP(hostname) isnt 0
        hostname
          .split('.')
          .reverse()
          .slice offset ? 0

    @public accepts: FuncG([MaybeG UnionG String, Array], UnionG String, Array, Boolean),
      default: (args...)-> @ctx.accept.types args...
    @public acceptsCharsets: FuncG([MaybeG UnionG String, Array], UnionG String, Array),
      default: (args...)-> @ctx.accept.charsets args...
    @public acceptsEncodings: FuncG([MaybeG UnionG String, Array], UnionG String, Array),
      default: (args...)-> @ctx.accept.encodings args...
    @public acceptsLanguages: FuncG([MaybeG UnionG String, Array], UnionG String, Array),
      default: (args...)-> @ctx.accept.languages args...

    @public 'is': FuncG([UnionG String, Array], UnionG String, Boolean, NilT),
      default: (args...)->
        [types] = args
        typeis = require 'type-is'
        return typeis @req unless types
        unless _.isArray types
          types = args
        typeis @req, types

    @public type: String,
      get: ->
        type = @get 'Content-Type'
        return '' unless type?
        type.split(';')[0]

    @public get: FuncG(String, String),
      default: (field)-> #@headers[name]
        req = @req
        switch field = field.toLowerCase()
          when 'referer', 'referrer'
            req.headers.referrer ? req.headers.referer ? ''
          else
            req.headers[field] ? ''

    # @public inspect: FuncG([], Object),
    #   default: ->
    #     return unless @req
    #     @toJSON()

    # @public toJSON: FuncG([], Object),
    #   default: -> _.pick @, ['method', 'url', 'header']

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: FuncG(ContextInterface, NilT),
      default: (context)->
        @super()
        @ctx = context
        @ip = @ips[0] ? @req.socket?.remoteAddress ? @req.remoteAddress ? ''
        return


    @initialize()
