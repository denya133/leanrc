_             = require 'lodash'
# joi           = require 'joi'
inflect       = require('i')()
RC            = require 'RC'


# TODO возможно стоит переименовать в Gateway - потому что объединяет несколько эндпоинтов (минимум crud-эндпоинты) (или не Gateway а BaseGateway, CrudGateway)
# по аналогии с Collection этот Gateway класс может хранить в качестве итемов (делегатов) объекты класса Endpoint
# возможно Crud эндпоинты можно подмешать миксином к Gateway или к целевым (по необходимости, авось в каких то классах не нужны будут крудовые эндпоинты а там только кастомные)

###
```coffee
LeanRC = require 'LeanRC'

module.exports = (App)->
  App::CrudGateway extends LeanRC::Gateway
    @inheritProtected()
    @include LeanRC::CrudEndpointsMixin

    @Module: App

  return App::CrudGateway.initialize()
```

```coffee
module.exports = (App)->
  App::PrepareModelCommand extends LeanRC::SimpleCommand
    @public execute: Function,
      default: ->
        #...
        @facade.registerProxy App::CrudGateway.new 'DefaultGateway',
          entityName: null # какие-то конфиги и что-то опорное для подключения эндов
        @facade.registerProxy App::CrudGateway.new 'CucumbersGateway',
          entityName: 'cucumber'
          schema: App::CucumberRecord.schema
        @facade.registerProxy App::CrudGateway.new 'TomatosGateway',
          entityName: 'tomato'
          schema: App::TomatoRecord.schema
          endpoints: {
            changeColor: App::TomatosChangeColorEndpoint.new()
          }
        @facade.registerProxy LeanRC::Gateway.new 'AuthGateway',
          entityName: 'user'
          endpoints: {
            signin: App::AuthSigninEndpoint.new()
            signout: App::AuthSignoutEndpoint.new()
            whoami: App::AuthWhoamiEndpoint.new()
          }
        #...
        return
```
###

module.exports = (LeanRC)->
  class LeanRC::Gateway extends LeanRC::Proxy
    @inheritProtected()
    @implements LeanRC::GatewayInterface

    @Module: LeanRC

    ipoEndpoints = @private endpoints: Object

    @public swaggerDefinition: Function,
      args: [String, Function]
      return: RC::Constants.NILL
      default: (asAction, lambda = (aoData)-> aoData)->
        voEndpoint = lambda.apply @, [LeanRC::Endpoint.new(gateway: @)]
        @[ipoEndpoints] ?= {}
        @[ipoEndpoints][asAction] = voEndpoint
        return

    @public swaggerDefinitionFor: Function,
      args: [String]
      return: LeanRC::EndpointInterface
      default: (asAction)-> @[ipoEndpoints]?[asAction]

    @public onRegister: Function,
      default: (args...)->
        @super args...
        {endpoints} = @getData()
        @[ipoEndpoints] = RC::Utils.extend {}, (@[ipoEndpoints] ? {}), endpoints
        return


    # вдвойне под вопросом, т.к. за сериализацию на уровне вьюхи должен отвечать другой класс
    # по задумке за эту часть должен отвечать ViewSerializer/Renderer который должен устанавливаться в медиаторе, поэтому здесь эта часть логики не нужна.
    @public @static prepareItem: Function,
      default: (item)->
        key = opts.singularize ? inflect.singularize inflect.underscore @::Model.name
        data = @serializeForClient item
        return "#{key}": data

    @public @static prepareList: Function,
      default: (items, meta)->
        key = opts.pluralize ? inflect.pluralize inflect.underscore @::Model.name
        results = []
        items.forEach (item) =>
          results.push @serializeForClient item
        return "#{key}": results, meta: meta

    @public @static serializeForClient: Function,
      default: (item)-> item


  return LeanRC::Gateway.initialize()
