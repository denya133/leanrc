# миксин может подмешиваться в наследники класса Resource

# !!! Необходимое условие использования миксина - Коллекция должна имплементировать QueryableMixinInterface

_ = require 'lodash'

module.exports = (Module)->
  {
    ANY
    ASYNC

    Resource
    ChainsMixin
  } = Module::

  Module.defineMixin Resource, (BaseClass) ->
    class BulkActionsResourceMixin extends BaseClass
      @inheritProtected()

      @action @async list: Function,
        default: ->
          vlItems = yield (yield @collection.query @query).toArray()
          return {
            meta:
              pagination:
                total: 'not defined'
                limit: 'not defined'
                offset: 'not defined'
            items: vlItems
          }

      @action @async bulkUpdate: Function,
        default: ->
          cursor = yield @collection.query @query
          body = @recordBody
          yield cursor.forEach (aoRecord) -> yield aoRecord.updateAttributes body
          return yes

      @action @async bulkPatch: Function,
        default: ->
          cursor = yield @collection.query @query
          body = @recordBody
          yield cursor.forEach (aoRecord) -> yield aoRecord.updateAttributes body
          return yes

      @action @async bulkDelete: Function,
        default: ->
          cursor = yield @collection.query @query
          yield cursor.forEach (aoRecord) -> yield aoRecord.destroy()
          return yes

      # ------------ Chains definitions ---------
      @chains [
        'list'
        'bulkUpdate', 'bulkPatch', 'bulkDelete'
      ]

      @beforeHook 'parseQuery', only: [
        'list'
        'bulkUpdate', 'bulkPatch', 'bulkDelete'
      ]
      @beforeHook 'parseBody', only: ['bulkUpdate', 'bulkPatch']
      @beforeHook 'omitBody', only: ['bulkUpdate', 'bulkPatch']

      @public parseQuery: Function,
        args: [Object]
        return: ANY
        default: (args...)->
          @query = JSON.parse @queryParams['query'] ? "{}"
          return args


    BulkActionsResourceMixin.initializeMixin()
