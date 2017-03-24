_             = require 'lodash'
joi           = require 'joi'
inflect       = require('i')()
status        = require 'statuses'
RC            = require 'RC'

HTTP_NOT_FOUND    = status 'not found'
HTTP_CONFLICT     = status 'conflict'
UNAUTHORIZED      = status 'unauthorized'
FORBIDDEN         = status 'forbidden'
UPGRADE_REQUIRED  = status 'upgrade required'

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

###

module.exports = (LeanRC)->
  class LeanRC::Gateway extends LeanRC::Proxy
    @inheritProtected()
    @implements LeanRC::GatewayInterface

    @Module: LeanRC

    ipoEndpoints = @private endpoints: Object

    ipoSchema = @private schema: Object # под вопросом???

    @public swaggerDefinition: Function,
      args: [String, Function]
      return: RC::Constants.NILL
      default: (asAction, lambda)->
        voEndpoint = lambda.apply @, [LeanRC::Endpoint.new(gateway: @)]
        @[ipoEndpoints] ?= {}
        @[ipoEndpoints][asAction] = voEndpoint
        return

    @public swaggerDefinitionFor: Function,
      args: [String]
      return: LeanRC::EndpointInterface
      default: (asAction)-> @[ipoEndpoints]?[asAction]

    # все что ниже под вопросом???

    @public @static schema: Function,
      default: ->
        joi.object @::Model.serializableAttributes()

    @public @static listSchema: Function,
      default: ->
        joi.object "#{inflect.pluralize inflect.underscore @::Model.name}": joi.array().items @schema()

    @public @static itemSchema: Function,
      default: ->
        joi.object "#{inflect.underscore @::Model.name}": @schema()


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
