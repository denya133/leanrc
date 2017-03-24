_             = require 'lodash'
joi           = require 'joi'
inflect       = require('i')()
status        = require 'statuses'
RC            = require 'RC'


# TODO возможно стоит переименовать в Gateway - потому что объединяет несколько эндпоинтов (минимум crud-эндпоинты) (или не Gateway а BaseGateway, CrudGateway)
# по аналогии с Collection этот Gateway класс может хранить в качестве итемов (делегатов) объекты класса Endpoint
# возможно Crud эндпоинты можно подмешать миксином к Gateway или к целевым (по необходимости, авось в каких то классах не нужны будут крудовые эндпоинты а там только кастомные)


module.exports = (LeanRC)->
  class LeanRC::Endpoint extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::EndpointInterface

    @Module: LeanRC

    @public gateway: LeanRC::GatewayInterface

    @public tag: Function,
      default: (asName)->
        return @

    @public header: Function,
      default: (asName, aoSchema, asDescription)->
        return @

    @public pathParam: Function,
      default: (asName, aoSchema, asDescription)->
        return @

    @public queryParam: Function,
      default: (asName, aoSchema, asDescription)->
        return @

    @public body: Function,
      default: (aoSchema, alMimes, asDescription)->
        return @

    @public response: Function,
      default: (anStatus, aoSchema, alMimes, asDescription)->
        return @

    @public error: Function,
      default: (anStatus, asDescription)->
        return @

    @public summary: Function,
      default: (asSummary)->
        return @

    @public description: Function,
      default: (asDescription)->
        return @

    @public deprecated: Function,
      default: (abDeprecated)->
        return @

    constructor: ({@gateway})->
      super arguments...


  return LeanRC::Endpoint.initialize()
