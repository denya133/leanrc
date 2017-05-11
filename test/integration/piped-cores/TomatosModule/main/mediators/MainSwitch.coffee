_             = require 'lodash'
express       = require 'express'
http          = require 'http'
crypto        = require 'crypto'
inflect       = do require 'i'
status        = require 'statuses'

expressCookieParser = require 'cookie-parser'
expressBodyParser   = require 'body-parser'

HTTP_NOT_FOUND    = status 'not found'
HTTP_CONFLICT     = status 'conflict'
UNAUTHORIZED      = status 'unauthorized'


module.exports = (Module)->
  {
    NILL
    CONFIGURATION
    APPLICATION_ROUTER
    APPLICATION_RENDERER

    Switch
  } = Module::

  class MainSwitch extends Switch
    @inheritProtected()
    @module Module

    @public routerName: String,
      default: APPLICATION_ROUTER
    @public jsonRendererName: String,
      default: APPLICATION_RENDERER

    ipoExpressApp = @private expressApp: Object
    ipoHttpServer = @private httpServer: Object

    @public onRegister: Function,
      default: ->
        @initExpressApp()
        @super()
        @serverListen()
        return

    @public onRemove: Function,
      default: ->
        @super()
        @[ipoHttpServer].close()
        return

    @public initExpressApp: Function,
      args: []
      return: NILL
      default: ->
        @[ipoExpressApp] = do express
        @[ipoExpressApp].use expressCookieParser @configs.cookieSecret
        @[ipoExpressApp].use expressBodyParser.json
          extended: yes
        @[ipoExpressApp].use expressBodyParser.urlencoded
          extended: yes
        # запихнуть сюда и другие миделвари
        @[ipoHttpServer] = http.createServer @[ipoExpressApp]
        return

    @public serverListen: Function,
      args: []
      return: NILL
      default: ->
        {port} = @configs
        @[ipoHttpServer].listen port, ->
          console.log "listening on port #{port}"
        return

    @public createNativeRoute: Function,
      default: ({method, path, resource, action})->
        resourceName = inflect.camelize inflect.underscore "#{resource.replace /[/]/g, '_'}Stock"

        @[ipoExpressApp][method]? path, (req, res)=>
          reverse = crypto.randomBytes 32
          @getViewComponent().once reverse, (voData)=>
            @sendHttpResponse req, res, voData, {method, path, resource, action}
          @handler resourceName, {req, res, reverse}, {method, path, resource, action}

        # это надо будет заиспользовать когда решится вопрос "как подрубить свайгер к экспрессу"
        # @defineSwaggerEndpoint voEndpoint
        return


  MainSwitch.initialize()
