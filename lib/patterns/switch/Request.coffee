_           = require 'lodash'
net         = require 'net' # will be used only 'isIP' function
contentType = require 'content-type'
stringify   = require('url').format
parse       = require 'parseurl'
qs          = require 'querystring'
typeis      = require 'type-is'
fresh       = require 'fresh'

###
Идеи взяты из https://github.com/koajs/koa/blob/master/lib/request.js
###

module.exports = (Module)->
  {
    ANY

    CoreObject
    RequestInterface
    ApplicationInterface
    ContextInterface
  } = Module::

  class Request extends CoreObject
    @inheritProtected()
    @implements RequestInterface
    @module Module

    @public req: Object, # native request object
      get: -> @ctx.req

    @public app: ApplicationInterface,
      get: -> @ctx.app

    @public ctx: ContextInterface

    # @public baseUrl: String # под вопросом?
    # @public body: ANY # тело должен предоставлять миксин из отдельного модуля
    # @public database: String # возможно это тоже надо получать из метода из отдельного модуля
    # @public pathname: String
    # @public pathParams: Object # вынести в отдельный модуль, который будет подключаться как миксин, а в чейнинге будет вызваться метод, который будет распарсивать парамсы
    # @public cookie: Function,
    #   default: (name, options)->

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
      get: -> parse(@req).pathname
      set: (path)->
        url = parse @req
        return if url.pathname is path
        url.pathname = path
        url.path = null
        @url = stringify url

    @public query: Object,
      get: -> qs.parse @querystring
      set: (obj)-> @querystring = qs.stringify obj

    @public querystring: String,
      get: ->
        return '' unless @req?
        parse(@req).query ? ''
      set: (str)->
        url = parse @req
        return if url.search is "?#{str}"
        url.search = str
        url.path = null
        @url = stringify url

    @public search: String,
      get: ->
        return '' unless @querystring
        "?#{@querystring}"
      set: (str)-> @querystring = str

    @public host: String,
      get: ->
        {trustProxy} = @ctx.app.configs
        host = trustProxy and @get 'X-Forwarded-Host'
        host = host or @get 'Host'
        return '' unless host
        host.split(/\s*,\s*/)[0]

    @public port: Number,
      get: ->
        host = @host
        port = if host
          host.split(':')[1]
        unless port
          port = if @protocol is 'https'
            443
          else
            80
        Number port

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
          return fresh @headers, @ctx.response.headers
        return no

    @public stale: Boolean,
      get: -> not @fresh

    @public idempotent: Boolean,
      get: ->
        methods = ['GET', 'HEAD', 'PUT', 'DELETE', 'OPTIONS', 'TRACE']
        _.includes methods, @method

    @public socket: Object,
      get: -> @req.socket

    @public charset: String,
      get: ->
        type = @get 'Content-Type'
        return '' unless type?
        try
          type = contentType.parse type
        catch err
          return ''
        type.parameters.charset ? ''

    @public length: Number,
      get: ->
        if (contentLength = @get 'Content-Length')?
          return if contentLength is ''
          ~~Number contentLength

    @public protocol: String,
      get: ->
        {trustProxy} = @ctx.app.configs
        if @socket?.encrypted
          return 'https'
        if @req.secure
          return 'https'
        unless trustProxy
          return 'http'
        proto = @get('X-Forwarded-Proto') ? 'http'
        proto.split(/\s*,\s*/)[0]

    @public xhr: Boolean,
      get: ->
        'xmlhttprequest' is String(@headers['X-Requested-With']).toLowerCase()

    @public secure: Boolean,
      get: -> @protocol is 'https'

    @public ip: String

    @public ips: Array,
      get: ->
        {trustProxy} = @ctx.app.configs
        value = @get 'X-Forwarded-For'
        if trustProxy and value
          value.split /\s*,\s*/
        else
          []

    @public subdomains: Array,
      get: ->
        {subdomainOffset:offset} = @ctx.app.configs
        hostname = @hostname
        return [] if net.isIP
        hostname
          .split('.')
          .reverse()
          .slice offset ? 0

    @public accepts: Function,
      default: (args...)-> @ctx.accept.types args...
    @public acceptsCharsets: Function,
      default: (args...)-> @ctx.accept.charsets args...
    @public acceptsEncodings: Function,
      default: (args...)-> @ctx.accept.encodings args...
    @public acceptsLanguages: Function,
      default: (args...)-> @ctx.accept.languages args...

    @public 'is': Function,
      default: (args...)->
        [types] = args
        return typeis @req unless types
        unless _.isArray types
          types = args
        typeis @req, types

    @public type: String,
      get: ->
        type = @get 'Content-Type'
        return '' unless type?
        type.split(';')[0]

    @public get: Function,
      default: (field)-> #@headers[name]
        req = @req
        switch field = field.toLowerCase()
          when 'referer', 'referrer'
            req.headers.referrer ? req.headers.referer ? ''
          else
            req.headers[field] ? ''

    @public inspect: Function,
      default: ->
        return unless @req
        @toJSON()

    @public toJSON: Function,
      default: -> _.pick @, ['method', 'url', 'header']

    @public init: Function,
      default: (context)->
        @super()
        @ctx = context
        @ip = @ips[0] ? @req.socket?.remoteAddress ? @req.remoteAddress ? ''
        return


  Request.initialize()
