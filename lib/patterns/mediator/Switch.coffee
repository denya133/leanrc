_             = require 'lodash'
EventEmitter  = require 'events'
statuses      = require 'statuses'
methods       = require 'methods'
pathToRegexp  = require 'path-to-regexp'
assert        = require 'assert'
Stream        = require 'stream'
inflect       = do require 'i'
onFinished    = require 'on-finished'


###
```coffee
module.exports = (Module)->
  class HttpSwitch extends Module::Switch
    @inheritProtected()
    @include Module::ArangoSwitchMixin

    @module Module

    @public routerName: String,
      default: 'ApplicationRouter'
    @public jsonRendererName: String,
      default: 'JsonRenderer'  # or 'ApplicationRenderer'
  HttpSwitch.initialize()
```
###


module.exports = (Module)->
  {
    ANY
    NILL
    LAMBDA
    MIGRATIONS
    APPLICATION_ROUTER
    APPLICATION_MEDIATOR
    HANDLER_RESULT

    Mediator
    Context
    SwitchInterface
    ConfigurableMixin
    Renderer
    Utils: {
      co
      isGeneratorFunction
      genRandomAlphaNumbers
    }
  } = Module::


  class Switch extends Mediator
    @inheritProtected()
    @implements SwitchInterface
    @include ConfigurableMixin
    @module Module

    @public @static compose: Function,
      args: [Array]
      return: LAMBDA
      default: (middlewares)->
        unless _.isArray middlewares
          throw new Error 'Middleware stack must be an array!'
        for fn in middlewares
          unless _.isFunction fn
            throw new Error 'Middleware must be composed of functions!'
        co.wrap (context)->
          for middleware in middlewares
            yield middleware context
          yield return

    # from https://github.com/koajs/route/blob/master/index.js ###############
    decode = (val)-> # чистая функция
      decodeURIComponent val if val
    matches = (ctx, method)->
      return yes unless method
      return yes if ctx.method is method
      if method is 'GET' and ctx.method is 'HEAD'
        return yes
      return no
    @public @static createMethod: Function,
      args: [String]
      return: NILL
      default: (method)->
        originMethodName = method
        if method
          method = method.toUpperCase()
        else
          originMethodName = 'all'

        @public "#{originMethodName}": Function,
          args: [String, LAMBDA]
          return: NILL
          default: (path, routeFunc)->
            unless routeFunc
              throw new Error 'handler is required'
            { facade } = @
            self = @
            {  ERROR, DEBUG, LEVELS, SEND_TO_LOG } = Module::LogMessage
            keys = []
            re = pathToRegexp path, keys
            facade.sendNotification SEND_TO_LOG, "#{method ? 'ALL'} #{path} -> #{re}", LEVELS[DEBUG]

            @use co.wrap (ctx)->
              unless matches ctx, method
                yield return
              m = re.exec ctx.path
              if m
                pathParams = m[1..]
                  .map decode
                  .reduce (prev, item, index)->
                    prev[keys[index].name] = item
                    prev
                  , {}
                ctx.routePath = path
                facade.sendNotification SEND_TO_LOG, "#{ctx.method} #{path} matches #{ctx.path} #{JSON.stringify pathParams}", LEVELS[DEBUG]
                ctx.pathParams = pathParams
                return yield routeFunc.call self, ctx
              yield return

            # это надо будет заиспользовать когда решится вопрос "как подрубить свайгер"
            #@defineSwaggerEndpoint voEndpoint
            return
        return

    methods.forEach (method)=>
      @createMethod method

    @public del: Function,
      default: (args...)->
        @delete args...

    @createMethod() # create @public all:...
    ##########################################################################

    @public responseFormats: Array,
      get: -> [
        'json', 'html', 'xml', 'atom', 'text'
      ]

    @public routerName: String,
      default: APPLICATION_ROUTER

    ipoHttpServer = @private httpServer: Object

    # @public jsonRendererName: String
    # @public htmlRendererName: String
    # @public xmlRendererName: String
    # @public atomRendererName: String

    @public listNotificationInterests: Function,
      default: ->
        [
          HANDLER_RESULT
        ]

    @public handleNotification: Function,
      default: (aoNotification)->
        vsName = aoNotification.getName()
        voBody = aoNotification.getBody()
        vsType = aoNotification.getType()
        switch vsName
          when HANDLER_RESULT
            @getViewComponent().emit vsType, voBody
        return

    @public onRegister: Function,
      default: ->
        voEmitter = new EventEmitter()
        if voEmitter.listeners('error').length is 0
          voEmitter.on 'error', @onerror.bind @
        @setViewComponent voEmitter
        @defineRoutes()
        @serverListen()
        return

    @public onRemove: Function,
      default: ->
        voEmitter = @getViewComponent()
        voEmitter.eventNames().forEach (eventName)->
          voEmitter.removeAllListeners eventName
        @[ipoHttpServer].close()
        return

    @public serverListen: Function,
      args: []
      return: NILL
      default: ->
        port = process?.env?.PORT ? @configs.port
        { facade } = @
        {  ERROR, DEBUG, LEVELS, SEND_TO_LOG } = Module::LogMessage
        http = require 'http'
        @[ipoHttpServer] = http.createServer @callback()
        @[ipoHttpServer].listen port, ->
          # console.log "listening on port #{port}"
          facade.sendNotification SEND_TO_LOG, "listening on port #{port}", LEVELS[DEBUG]
        return

    @public middlewares: Array

    @public use: Function,
      args: [LAMBDA]
      return: SwitchInterface
      default: (middleware)->
        unless _.isFunction middleware
          throw new Error 'middleware must be a function!'
        if isGeneratorFunction middleware
          { name: oldName } = middleware
          middleware = co.wrap middleware
          middleware._name = oldName
        middlewareName = middleware._name ? middleware.name ? '-'
        {  ERROR, DEBUG, LEVELS, SEND_TO_LOG } = Module::LogMessage
        @facade.sendNotification SEND_TO_LOG, "use #{middlewareName}", LEVELS[DEBUG]
        @middlewares.push middleware
        return @

    @public callback: Function,
      args: []
      return: LAMBDA
      default: ->
        fn = @constructor.compose @middlewares
        handleRequest = co.wrap (req, res)=>
          res.statusCode = 404
          voContext = Context.new req, res, @
          try
            yield fn voContext
            @respond voContext
          catch err
            voContext.onerror err

          onFinished res, (err)->
            voContext.onerror err
            return
          yield return
        handleRequest

    # Default error handler
    @public onerror: Function,
      args: [Error]
      return: LAMBDA
      default: (err)->
        assert _.isError(err), "non-error thrown: #{err}"
        return if 404 is err.status or err.expose
        return if @configs.silent
        msg = err.stack ? String err
        {  ERROR, DEBUG, LEVELS, SEND_TO_LOG } = Module::LogMessage
        @facade.sendNotification SEND_TO_LOG, msg.replace(/^/gm, '  '), LEVELS[ERROR]
        return

    @public respond: Function,
      default: (ctx)->
        return if ctx.respond is no
        return unless ctx.writable
        body = ctx.body
        code = ctx.status
        if statuses.empty[code]
          ctx.body = null
          return ctx.res.end()
        if 'HEAD' is ctx.method
          if not ctx.res.headersSent and _.isObjectLike body
            ctx.length = Buffer.byteLength JSON.stringify body
          return ctx.res.end()
        unless body?
          body = ctx.message ? String code
          unless ctx.res.headersSent
            ctx.type = 'text'
            ctx.length = Buffer.byteLength body
          return ctx.res.end body
        if _.isBuffer(body) or _.isString body
          return ctx.res.end body
        if body instanceof Stream
          return body.pipe ctx.res
        body = JSON.stringify body ? null
        unless ctx.res.headersSent
          ctx.length = Buffer.byteLength body
        ctx.res.end body
        return

    ipoRenderers = @private renderers: Object

    @public rendererFor: Function,
      default: (asFormat)->
        @[ipoRenderers] ?= {}
        @[ipoRenderers][asFormat] ?= do (asFormat)=>
          voRenderer = if @["#{asFormat}RendererName"]?
            @facade.retrieveProxy @["#{asFormat}RendererName"]
          voRenderer ?= Renderer.new()
          voRenderer
        @[ipoRenderers][asFormat]

    @public @async sendHttpResponse: Function,
      default: (ctx, aoData, resource, opts)->
        if opts.action is 'create'
          ctx.status = 201
        unless ctx.headers?.accept?
          yield return
        switch (vsFormat = ctx.accepts @responseFormats)
          when no
          else
            if @["#{vsFormat}RendererName"]?
              voRenderer = @rendererFor vsFormat
              voRendered = yield voRenderer
                .render ctx, aoData, resource, opts
              ctx.body = voRendered
        yield return

    @public defineRoutes: Function,
      default: ->
        voRouter = @facade.retrieveProxy @routerName ? APPLICATION_ROUTER
        voRouter.routes.forEach (aoRoute)=>
          @createNativeRoute aoRoute
        return

    @public sender: Function,
      default: (resourceName, aoMessage, {method, path, resource, action})->
        @sendNotification resourceName, aoMessage, action
        return

    # @public defineSwaggerEndpoint: Function,
    #   default: (aoSwaggerEndpoint, resourceName, action)->
    #     voGateway = @facade.retrieveProxy "#{resourceName}Gateway"
    #     {
    #       tags
    #       headers
    #       pathParams
    #       queryParams
    #       payload
    #       responses
    #       errors
    #       title
    #       synopsis
    #       isDeprecated
    #     } = voGateway.swaggerDefinitionFor action
    #     tags?.forEach (tag)->
    #       aoSwaggerEndpoint.tag tag
    #     headers?.forEach ({name, schema, description})->
    #       aoSwaggerEndpoint.header name, schema, description
    #     pathParams?.forEach ({name, schema, description})->
    #       aoSwaggerEndpoint.pathParam name, schema, description
    #     queryParams?.forEach ({name, schema, description})->
    #       aoSwaggerEndpoint.queryParam name, schema, description
    #     if payload?
    #       aoSwaggerEndpoint.body payload.schema, payload.mimes, payload.description
    #     responses?.forEach ({status, schema, mimes, description})->
    #       aoSwaggerEndpoint.response status, schema, mimes, description
    #     errors?.forEach ({status, description})->
    #       aoSwaggerEndpoint.error status, description
    #     aoSwaggerEndpoint.summary title            if title?
    #     aoSwaggerEndpoint.description synopsis     if synopsis?
    #     aoSwaggerEndpoint.deprecated isDeprecated  if isDeprecated?
    #     return

    @public createNativeRoute: Function,
      default: (opts)->
        {method, path} = opts
        resourceName = inflect.camelize inflect.underscore "#{opts.resource.replace /[/]/g, '_'}Resource"

        @[method]? path, co.wrap (context)=>
          yield Module::Promise.new (resolve, reject)=>
            try
              reverse = genRandomAlphaNumbers 32
              @getViewComponent().once reverse, co.wrap ({error, result, resource})=>
                if error?
                  console.log '>>>>>> ERROR AFTER RESOURCE', error
                  reject error
                  yield return
                try
                  yield @sendHttpResponse context, result, resource, opts
                  resolve()
                  yield return
                catch err
                  reject err
                  yield return
              @sender resourceName, {context, reverse}, opts
            catch err
              reject err
            return
          yield return
        return

    @public init: Function,
      default: (args...)->
        @super args...
        @middlewares = []
        return


  Switch.initialize()
