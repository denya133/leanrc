# надо реализовать в отдельном модуле (npm-пакете) так как является платформозависимым
# здесь должна быть реализация интерфейса RouteInterface работающая с Foxx роутером.

_             = require 'lodash'
inflect       = require('i')()
FoxxRouter    = require '@arangodb/foxx/router'
{ db }        = require '@arangodb'
queues        = require '@arangodb/foxx/queues'
crypto        = require '@arangodb/crypto'
status        = require 'statuses'
{ errors }    = require '@arangodb'
RC            = require 'RC'
LeanRC        = require 'LeanRC'

ARANGO_NOT_FOUND  = errors.ERROR_ARANGO_DOCUMENT_NOT_FOUND.code
ARANGO_DUPLICATE  = errors.ERROR_ARANGO_UNIQUE_CONSTRAINT_VIOLATED.code
ARANGO_CONFLICT   = errors.ERROR_ARANGO_CONFLICT.code
HTTP_NOT_FOUND    = status 'not found'
HTTP_CONFLICT     = status 'conflict'
UNAUTHORIZED      = status 'unauthorized'

# здесь (наверху) надо привести пример использования в приложении
###
```coffee
LeanRC = require 'LeanRC'

module.exports = (App)->
  class App::FoxxMediator extends LeanRC::Mediator
    @inheritProtected()
    @include LeanRC::ArangoRouteMixin

    @Module: App
  return App::FoxxMediator.initialize()
```
###


# class FoxxRouterMixinInterface extends Interface
#   @include RouterMixinInterface

# TODO: надо подумать над тем, что возможно стоит создать класс LeanRC::Route - от которого наследоваться и куда подмешивать ArangoRouteMixin
# это будет оправдано, если наберется много общей платформонезависимой логики здесь.

# TODO: надо подобрать правильное (подходящее) название для `App::FoxxMediator`

module.exports = (ArangoExt)->
  class ArangoExt::ArangoRouteMixin extends RC::Mixin
    @inheritProtected()
    @implements LeanRC::RouteInterface # или вообще не указывать

    @Module: ArangoExt

    @public listNotificationInterests: Function,
      default: ->
        [
          LeanRC::Constants.DEFINE_ROUTE
          LeanRC::Constants.RESOURCE_RESULT
        ]

    @public handleNotification: Function,
      default: (aoNotification)->
        vsName = aoNotification.getName()
        voBody = aoNotification.getBody()
        vsType = aoNotification.getType()
        switch vsName
          case LeanRC::Constants.DEFINE_ROUTE
            @createNativeRoute voBody
          case LeanRC::Constants.RESOURCE_RESULT
            @getViewComponent().emit vsType, voBody
        return

    @public onRegister: Function,
      # в express и koa тут можно создать сервер и положить его приватную перем.
      default: ->
        EventEmitter = require 'events'
        @setViewComponent new EventEmitter()
        return # обычно навешивают ивент-листенеры на @viewComponent

    @public onRemove: Function,
      default: ->
        voEmitter = @getViewComponent()
        voEmitter.eventNames().forEach (eventName)->
          voEmitter.removeAllListeners eventName
        return # обычно удаляют ивент-листенеры на @viewComponent

    @public getLocks: Function,
      args: []
      return: Object # {read, write}
      default: ->
        # вычислить относительно текущего @constructor.Module какие имена коллекций будут задействованы в этом модуле, и передать все эти имена на return

    @public sendResponse: Function,
      args: [Object, Object, Object]
      return: RC::Constants.NILL
      default: (req, res, aoData)->
        if aoData?.constructor?.name is 'SyntheticResponse'
          return # ничего не делаем, если `res.send` уже был вызван ранее
        # здесь надо пропустить данные через ViewSerializer и потом результат отправить на рендеринг, после чего отправить готовый ответ by `res.send`
        # !!! вопрос в том, как это сделать в наиболее удобной форме.

    @public createNativeRoute: Function,
      args: [Object]
      return: RC::Constants.NILL
      default: ({method, path, resource, action})->
        voRouter = FoxxRouter()
        resourceName = inflect.camelize inflect.underscore "#{resource.replace /[/]/g, '_'}Resource"

        voEndpoint = voRouter[method]? [path, (req, res)=>
          reverse = crypto.genRandomAlphaNumbers 32
          @getViewComponent().once reverse, (voData)=>
            @sendResponse req, res, voData
          try
            if method is 'get'
              @sendNotification resourceName, {req, res, reverse}, action
            else
              {read, write} = @getLocks()
              self = @
              db._executeTransaction
                waitForSync: yes
                collections:
                  read: read
                  write: write
                  allowImplicit: no
                action: (params)->
                  params.self.sendNotification params.resourceName, {params.req, params.res, params.reverse}, params.action
                params: {resourceName, action, req, res, reverse, self}
            queues._updateQueueDelay()
          catch err
            console.log '???????????????????!!', JSON.stringify err
            if err.isArangoError and err.errorNum is ARANGO_NOT_FOUND
              res.throw HTTP_NOT_FOUND, err.message
              return
            if err.isArangoError and err.errorNum is ARANGO_CONFLICT
              res.throw HTTP_CONFLICT, err.message
              return
            else if err.statusCode?
              console.error err.message, err.stack
              res.throw err.statusCode, err.message
            else
              console.error 'kkkkkkkk', err.message, err.stack
              res.throw 500, err.message, err.stack
              return
        , action]...

        @constructor["_swaggerDefFor_#{action}"]? [voEndpoint]...
        # TODO: на счет свайгер дифинишенов как минимум дефолтные можно поместить в этом классе,
        # однако что делать и где объявлять кастомные дефинишены для кастомных экшенов???
        # вообще говоря надо выяснить как подключать свайгер к экспрессу (koa) чтобы добиться однотипности.

        # TODO: надо решить что с этим делать??? - т.к. в модуле нет больше контекста.
        # теоретически можно прямо здесь (где платформозависимый код) просто сделать вызов module.context.use voRouter
        module.context.use voRouter
        return


  return ArangoExt::ArangoRouteMixin.initialize()
