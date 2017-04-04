RC = require 'RC'
EventEmitter = require 'events'


module.exports = (LeanRC)->
  class LeanRC::Switch extends LeanRC::Mediator
    @inheritProtected()
    @implements LeanRC::SwitchInterface

    @Module: LeanRC

    @public responseFormats: Array,
      get: -> ['json', 'html', 'xml', 'atom']

    # должены быть объявлены в унаследованном классе
    # @public routerName: String

    # @public jsonRendererName: String
    # @public htmlRendererName: String
    # @public xmlRendererName: String
    # @public atomRendererName: String

    @public listNotificationInterests: Function,
      configurable: yes
      default: ->
        [
          LeanRC::Constants.HANDLER_RESULT
        ]

    @public handleNotification: Function,
      default: (aoNotification)->
        vsName = aoNotification.getName()
        voBody = aoNotification.getBody()
        vsType = aoNotification.getType()
        switch vsName
          when LeanRC::Constants.HANDLER_RESULT
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
      args: [String]
      return: LeanRC::RendererInterface
      default: (asFormat)->
        @[ipoRenderers] ?= {}
        @[ipoRenderers][asFormat] ?= do (asFormat)=>
          voRenderer = if @["#{asFormat}RendererName"]?
            @facade.retrieveProxy @["#{asFormat}RendererName"]
          voRenderer ?= LeanRC::Renderer.new()
          voRenderer
        @[ipoRenderers][asFormat]

    @public sendHttpResponse: Function,
      args: [Object, Object, Object, Object]
      return: RC::Constants.NILL
      default: (req, res, aoData, {path, resource, action})->
        switch (vsFormat = req.accepts @responseFormats)
          when 'json', 'html', 'xml', 'atom'
            if @["#{vsFormat}RendererName"]?
              voRendered = @rendererFor vsFormat
                .render aoData, {path, resource, action}
            else
              res.setHeader 'Content-Type', 'text/plain'
              voRendered = JSON.stringify aoData
            res.send voRendered
          else
            res.setHeader 'Content-Type', 'text/plain'
            res.send JSON.stringify aoData
        return

    @public defineRoutes: Function,
      args: []
      return: RC::Constants.NILL
      default: ->
        voRouter = @facade.retrieveProxy @routerName
        voRouter.routes.forEach (aoRoute)=>
          @createNativeRoute aoRoute
        return

    # этот метод можно переопределить добавив в конкретный медиатор после этого миксина другой, содержащий этот метод.
    # так может быть реализовано например в случае, когда нужно чтобы внутри хендлера открывалась транзакция для работы с базой данных. (и после выполнения закрывалась)
    @public handler: Function,
      args: []
      return: RC::Constants.NILL
      default: (resourceName, {req, res, reverse}, {method, path, resource, action})->
        queryParams = req.query
        pathPatams = req.params
        currentUserId = req.cookies[@getData().currentUserCookie]
        headers = req.headers
        body = req.body
        voMessage = {
          queryParams
          pathPatams
          currentUserId
          headers
          body
          reverse
        }
        @sendNotification resourceName, voMessage, action
        return

    @public defineSwaggerEndpoint: Function,
      args: [Object]
      return: RC::Constants.NILL
      default: (aoSwaggerEndpoint)->
        voGateway = @facade.retrieveProxy "#{resourceName}Gateway"
        {
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
    # @public createNativeRoute: Function,


  return LeanRC::Switch.initialize()
