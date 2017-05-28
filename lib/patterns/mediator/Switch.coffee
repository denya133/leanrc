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
    APPLICATION_ROUTER
    APPLICATION_MEDIATOR
    HANDLER_RESULT

    Mediator
    Context
    SwitchInterface
    ConfigurableMixin
    Renderer
    Utils
  } = Module::
  {
    co
    isGeneratorFunction
    isArangoDB
  } = Utils


  class Switch extends Mediator
    @inheritProtected()
    @implements SwitchInterface
    @include ConfigurableMixin
    @module Module

    # from https://github.com/koajs/compose/blob/master/index.js #############
    @public @static compose: Function,
      args: [Array]
      return: LAMBDA
      default: (middlewares)->
        unless _.isArray middlewares
          throw new Error 'Middleware stack must be an array!'
        for fn in middlewares
          unless _.isFunction fn
            throw new Error 'Middleware must be composed of functions!'
        (context, next)->
          index = -1
          dispatch = (i)->
            console.log 'IN >>> compose|dispatch'
            if i <= index
              return Module::Promise.reject new Error 'next() called multiple times'
            index = i
            middleware = middlewares[i]
            if i is middlewares.length
              console.log '!!!!!!!!!!!!!!!@@@@@@@@@@@@@ next', next
              middleware = next
            return Module::Promise.resolve() unless middleware?
            try
              return Module::Promise.resolve middleware context, -> dispatch i+1
            catch err
              return Module::Promise.reject err
          dispatch 0
    ##########################################################################

    # from https://github.com/koajs/route/blob/master/index.js ###############
    decode = (val)-> # чистая функция
      decodeURIComponent val if val
    matches = (ctx, method)-> # чистая функция
      console.log 'IN >>> matches', ctx.method, method
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
          default: (path, fn)->
            { facade } = @
            self = @
            {  ERROR, DEBUG, LEVELS, SEND_TO_LOG } = Module::LogMessage
            keys = []
            re = pathToRegexp path, keys
            facade.sendNotification SEND_TO_LOG, "#{method ? 'ALL'} #{path} -> #{re}", LEVELS[DEBUG]

            createRoute = (routeFunc)->
              (ctx, next)->
                console.log 'IN createRoute >>>>', ctx.method, method, path, ctx.path, matches ctx, method
                unless matches ctx, method
                  return next()
                m = re.exec ctx.path
                if m
                  pathParams = m.slice(1)
                    .map decode
                    .reduce (prev, item, index)->
                      prev[keys[index].name] = item
                      prev
                    , {}
                  ctx.routePath = path
                  facade.sendNotification SEND_TO_LOG, "#{ctx.method} #{path} matches #{ctx.path} #{pathParams}", LEVELS[DEBUG]
                  ctx.pathParams = pathParams
                  return Module::Promise.resolve routeFunc.apply self, [ctx, next]
                  # return Module::Promise.resolve routeFunc ctx, next
                return next()
            @use if fn
              createRoute fn
            else
              createRoute
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
      get: -> ['json', 'html', 'xml', 'atom']

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
        @setViewComponent new EventEmitter()
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
        {port} = @configs
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
          middleware = co.wrap middleware
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
        voEmitter = @getViewComponent()
        if voEmitter.listeners('error').length is 0
          voEmitter.on 'error', @onerror.bind @
        handleRequest = (req, res)=>
          res.statusCode = 404
          voContext = Context.new req, res, @
          onerror = (err)=>
            console.log 'IN Switch::callback|handleRequest|onerror', err
            voContext.onerror err
          handleResponse = =>
            console.log 'IN Switch::callback|handleRequest|handleResponse'
            @respond voContext
          onFinished res, onerror
          fn(voContext).then(handleResponse).catch(onerror)
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
        console.log 'IN Switch::respond', ctx.writable
        return if context.respond is no
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
        body = JSON.stringify body
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
      default: (ctx, aoData, {method, path, resource, action})->
        if action is 'create'
          ctx.status = 201
        console.log 'before switch', ctx.accepts @responseFormats
        switch (vsFormat = ctx.accepts @responseFormats)
          when 'json', 'html', 'xml', 'atom'
            if @["#{vsFormat}RendererName"]?
              voRenderer = @rendererFor vsFormat
              voRendered = yield voRenderer
                .render aoData, {path, resource, action}
            else
              ctx.set 'Content-Type', 'text/plain'
              voRendered = JSON.stringify aoData
            console.log '>>> before ctx.body = voRendered', voRendered
            ctx.body = voRendered
            console.log '>>> after ctx.body = voRendered'
          else
            ctx.set 'Content-Type', 'text/plain'
            ctx.body = JSON.stringify aoData
        yield return

    @public defineRoutes: Function,
      default: ->
        voRouter = @facade.retrieveProxy @routerName ? APPLICATION_ROUTER
        voRouter.routes.forEach (aoRoute)=>
          @createNativeRoute aoRoute
        return

    @public sender: Function,
      default: (resourceName, aoMessage, {method, path, resource, action})->
        # queryParams = req.query
        # pathParams = req.params
        # currentUserId = req.cookies[@configs.currentUserCookie]
        # headers = req.headers
        # body = req.body
        # voMessage = {
        #   queryParams
        #   pathParams
        #   currentUserId
        #   headers
        #   body
        #   reverse
        # }

        @sendNotification resourceName, aoMessage, action
        return

    @public defineSwaggerEndpoint: Function,
      default: (aoSwaggerEndpoint, resourceName, action)->
        voGateway = @facade.retrieveProxy "#{resourceName}Gateway"
        {
          tags
          headers
          pathParams
          queryParams
          payload
          responses
          errors
          title
          synopsis
          isDeprecated
        } = voGateway.swaggerDefinitionFor action
        tags?.forEach (tag)->
          aoSwaggerEndpoint.tag tag
        headers?.forEach ({name, schema, description})->
          aoSwaggerEndpoint.header name, schema, description
        pathParams?.forEach ({name, schema, description})->
          aoSwaggerEndpoint.pathParam name, schema, description
        queryParams?.forEach ({name, schema, description})->
          aoSwaggerEndpoint.queryParam name, schema, description
        if payload?
          aoSwaggerEndpoint.body payload.schema, payload.mimes, payload.description
        responses?.forEach ({status, schema, mimes, description})->
          aoSwaggerEndpoint.response status, schema, mimes, description
        errors?.forEach ({status, description})->
          aoSwaggerEndpoint.error status, description
        aoSwaggerEndpoint.summary title            if title?
        aoSwaggerEndpoint.description synopsis     if synopsis?
        aoSwaggerEndpoint.deprecated isDeprecated  if isDeprecated?
        return

    # должен быть объявлен в унаследованном классе
    @public createNativeRoute: Function,
      default: ({method, path, resource, action})->
        resourceName = inflect.camelize inflect.underscore "#{resource.replace /[/]/g, '_'}Resource"

        @[method]? path, (context, next)=>
          console.log '>>>!!! 000'
          reverse = if isArangoDB()
            crypto = require '@arangodb/crypto'
            crypto.genRandomAlphaNumbers 32
          else
            crypto = require 'crypto'
            crypto.randomBytes 32
          console.log '>>>!!! 111'
          @getViewComponent().once reverse, co.wrap (aoData)=>
            console.log '>>>!!! 222', aoData
            yield @sendHttpResponse context, aoData, {method, path, resource, action}
            console.log '>>> after @sendHttpResponse'
            yield return next()
            # return yield next()
          console.log '>>>!!! before sender ', resourceName, method, path, resource, action, context
          @sender resourceName, {context, reverse}, {method, path, resource, action}
          console.log '>>>!!! after sender '
          return
        return

    @public init: Function,
      default: (args...)->
        @super args...
        @middlewares = []
        return


  Switch.initialize()
