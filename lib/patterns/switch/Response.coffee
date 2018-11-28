# contentDisposition  = require 'content-disposition'
# ensureErrorHandler  = require 'error-inject'
# getType             = require('mime-types').contentType
# onFinish            = require 'on-finished'
# escape              = require 'escape-html'
# typeis              = require('type-is').is
# destroy             = require 'destroy'
# assert              = require 'assert'
# extname             = require('path').extname
# vary                = require 'vary'
# Stream              = require 'stream'

###
Идеи взяты из https://github.com/koajs/koa/blob/master/lib/response.js
###
Stream = require 'stream'


module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, UnionG, MaybeG
    ResponseInterface, SwitchInterface, ContextInterface
    CoreObject
    Utils: { _, statuses }
  } = Module::

  class Response extends CoreObject
    @inheritProtected()
    @implements ResponseInterface
    @module Module

    @public res: Object, # native response object
      get: -> @ctx.res

    @public switch: SwitchInterface,
      get: -> @ctx.switch

    @public ctx: ContextInterface

    @public socket: Object,
      get: -> @ctx.req.socket

    @public header: Object,
      get: -> @headers
    @public headers: Object,
      get: ->
        if _.isFunction @res.getHeaders
          @res.getHeaders()
        else
          @res._headers ? {}

    @public status: MaybeG(Number),
      get: -> @res.statusCode
      set: (code)->
        assert = require 'assert'
        assert _.isNumber(code), 'status code must be a number'
        assert statuses[code], "invalid status code: #{code}"
        assert not @res.headersSent, 'headers have already been sent'
        @_explicitStatus = yes
        @res.statusCode = code
        @res.statusMessage = statuses[code]
        if Boolean(@body and statuses.empty[code])
          @body = null
        return code

    @public message: String,
      get: -> @res.statusMessage ? statuses[@status]
      set: (msg)->
        @res.statusMessage = msg
        return msg

    @public body: MaybeG(UnionG String, Buffer, Object, Array, Number, Boolean, Stream),
      get: -> @_body
      set: (val)->
        original = @_body
        @_body = val
        return if @res.headersSent
        unless val?
          unless statuses.empty[@status]
            @status = 204
          @remove 'Content-Type'
          @remove 'Content-Length'
          @remove 'Transfer-Encoding'
          return
        unless @_explicitStatus
          @status = 200
        setType = not @headers['content-type']
        if _.isString val
          if setType
            @type = if /^\s*</.test val then 'html' else 'text'
          @length = Buffer.byteLength val
          return
        if _.isBuffer val
          if setType
            @type = 'bin'
          @length = val.length
          return
        if _.isFunction val.pipe
          onFinish = require 'on-finished'
          destroy = require 'destroy'
          onFinish @res, destroy.bind null, val
          ensureErrorHandler = require 'error-inject'
          ensureErrorHandler val, (err)=> @ctx.onerror err
          if original? and original isnt val
            @remove 'Content-Length'
          if setType
            @type = 'bin'
          return
        @remove 'Content-Length'
        @type = 'json'
        return val

    # @public body: [String, Buffer]
    # @public locals: Object
    # @public headers: Object
    # @public statusCode: Number


    # @public cookie: Function,
    #   default: (name, value, options = null)->

    # @public download: Function,
    #   default: (path, filename)->

    # @public json: Function,
    #   default: (data)->


    # @public removeHeader: Function,
    #   default: (name)->
    #
    # @public send: Function,
    #   args: [[Buffer, String, Object, Array, Number, Boolean]]
    #   default: (data)->

    # @public sendFile: Function,
    #   default: (path, options = null)->

    # @public sendStatus: Function,
    #   default: (status)->



    # @public throw: Function,
    #   return: NILL
    #   default: (status, reason, options = null)->


    # @public write: Function,
    #   args: [[String, Buffer]]
    #   default: (data)->

    @public length: Number,
      get: ->
        len = @headers['content-length']
        unless len?
          return 0 unless @body
          if _.isString @body
            return Buffer.byteLength @body
          if _.isBuffer @body
            return @body.length
          if _.isObjectLike @body
            return Buffer.byteLength JSON.stringify @body
          return 0
        ~~Number len
      set: (n)->
        @set 'Content-Length', n
        return n

    @public headerSent: MaybeG(Boolean),
      get: -> @res.headersSent

    @public vary: FuncG(String, NilT),
      default: (field)->
        vary = require 'vary'
        vary @res, field
        return

    @public redirect: FuncG([String, MaybeG String], NilT),
      default: (url, alt)->
        if 'back' is url
          url = @ctx.get('Referrer') or alt or '/'
        @set 'Location', url
        unless statuses.redirect[@status]
          @status = 302
        if @ctx.accepts 'html'
          escape = require 'escape-html'
          url = escape url
          @type = 'text/html; charset=utf-8'
          @body = "Redirecting to <a href=\"#{url}\">#{url}</a>."
          return
        @type = 'text/plain; charset=utf-8'
        @body = "Redirecting to #{url}"
        return

    @public attachment: FuncG(String, NilT),
      default: (filename)->
        if filename
          extname = require('path').extname
          @type = extname filename
        contentDisposition = require 'content-disposition'
        @set 'Content-Disposition', contentDisposition filename
        return

    @public lastModified: MaybeG(Date),
      get: ->
        date = @get 'last-modified'
        if date
          new Date date
      set: (val)->
        if _.isString val
          val = new Date val
        @set 'Last-Modified', val.toUTCString()
        return val

    @public etag: String,
      get: -> @get 'ETag'
      set: (val)->
        val = "\"#{val}\"" unless /^(W\/)?"/.test val
        @set 'ETag', val
        return val

    @public type: MaybeG(String),
      get: ->
        type = @get 'Content-Type'
        return '' unless type
        type.split(';')[0]
      set: (_type)->
        getType = require('mime-types').contentType
        type = getType _type
        if type
          @set 'Content-Type', type
        else
          @remove 'Content-Type'
        return _type

    @public 'is': FuncG([UnionG String, Array], UnionG String, Boolean, NilT),
      default: (args...)->
        [types] = args
        return @type or no unless types
        unless _.isArray types
          types = args
        typeis = require('type-is').is
        typeis @type, types

    @public get: FuncG(String, UnionG String, Array),
      default: (field)->
        @headers[field.toLowerCase()] ? ''

    @public set: FuncG([UnionG(String, Object), MaybeG AnyT], NilT),
      default: (args...)->
        [field, val] = args
        if 2 is args.length
          if _.isArray val
            val = val.map String
          else
            val = String val
          @res.setHeader field, val
        else
          for own key, value of field
            @set key, value
        return

    @public append: FuncG([String, UnionG String, Array], NilT),
      default: (field, val)->
        prev = @get field
        if prev
          if _.isArray prev
            val = prev.concat val
          else
            val = [prev].concat val
        @set field, val
        return

    @public remove: FuncG(String, NilT),
      default: (field)->
        @res.removeHeader field
        return

    @public writable: Boolean,
      get: ->
        return no if @res.finished
        socket = @res.socket
        return yes unless socket
        socket.writable

    @public flushHeaders: Function,
      default: ->
        if _.isFunction @res.flushHeaders
          @res.flushHeaders()
        else
          headerNames = if _.isFunction @res.getHeaderNames
            @res.getHeaderNames()
          else
            Object.keys @res._headers
          for header in headerNames
            @res.removeHeader header
        return

    # @public inspect: FuncG([], Object),
    #   default: ->
    #     return unless @res
    #     o = @toJSON()
    #     o.body = @body
    #     o

    # @public toJSON: FuncG([], Object),
    #   default: -> _.pick @, ['status', 'message', 'header']

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
        return


    @initialize()
