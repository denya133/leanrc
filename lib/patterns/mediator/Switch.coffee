
EventEmitter = require 'events'


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
    APPLICATION_ROUTER
  } = Module::

  class Switch extends Module::Mediator
    @inheritProtected()
    @implements Module::SwitchInterface
    @include Module::ConfigurableMixin
    @module Module

    @public responseFormats: Array,
      get: -> ['json', 'html', 'xml', 'atom']

    @public routerName: String,
      default: APPLICATION_ROUTER

    # @public jsonRendererName: String
    # @public htmlRendererName: String
    # @public xmlRendererName: String
    # @public atomRendererName: String

    @public listNotificationInterests: Function,
      default: ->
        [
          Module::HANDLER_RESULT
        ]

    @public handleNotification: Function,
      default: (aoNotification)->
        vsName = aoNotification.getName()
        voBody = aoNotification.getBody()
        vsType = aoNotification.getType()
        switch vsName
          when Module::HANDLER_RESULT
            @getViewComponent().emit vsType, voBody
        return

    @public onRegister: Function,
      default: ->
        @setViewComponent new EventEmitter()
        @defineRoutes()
        return

    @public onRemove: Function,
      default: ->
        voEmitter = @getViewComponent()
        voEmitter.eventNames().forEach (eventName)->
          voEmitter.removeAllListeners eventName
        return

    ipoRenderers = @private renderers: Object

    @public rendererFor: Function,
      default: (asFormat)->
        @[ipoRenderers] ?= {}
        @[ipoRenderers][asFormat] ?= do (asFormat)=>
          voRenderer = if @["#{asFormat}RendererName"]?
            @facade.retrieveProxy @["#{asFormat}RendererName"]
          voRenderer ?= Module::Renderer.new()
          voRenderer
        @[ipoRenderers][asFormat]

    @public @async sendHttpResponse: Function,
      default: (req, res, aoData, {method, path, resource, action})->
        if action is 'create'
          res.status 201
        switch (vsFormat = req.accepts @responseFormats)
          when 'json', 'html', 'xml', 'atom'
            if @["#{vsFormat}RendererName"]?
              voRenderer = @rendererFor vsFormat
              voRendered = yield voRenderer
                .render aoData, {path, resource, action}
            else
              res.set 'Content-Type', 'text/plain'
              voRendered = JSON.stringify aoData
            res.send voRendered
          else
            res.set 'Content-Type', 'text/plain'
            res.send JSON.stringify aoData
        yield return

    @public defineRoutes: Function,
      default: ->
        voRouter = @facade.retrieveProxy @routerName ? APPLICATION_ROUTER
        voRouter.routes.forEach (aoRoute)=>
          @createNativeRoute aoRoute
        return

    # этот метод можно переопределить добавив в конкретный медиатор после этого миксина другой, содержащий этот метод.
    # так может быть реализовано например в случае, когда нужно чтобы внутри хендлера открывалась транзакция для работы с базой данных. (и после выполнения закрывалась)
    @public handler: Function,
      default: (resourceName, {req, res, reverse}, {method, path, resource, action})->
        queryParams = req.query
        pathParams = req.params
        currentUserId = req.cookies[@configs.currentUserCookie]
        headers = req.headers
        body = req.body
        voMessage = {
          queryParams
          pathParams
          currentUserId
          headers
          body
          reverse
        }
        @sendNotification resourceName, voMessage, action
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
      default: ->
        throw new Error '`Switch::createNativeRoute` should be implemeted in derived class'


  Switch.initialize()
