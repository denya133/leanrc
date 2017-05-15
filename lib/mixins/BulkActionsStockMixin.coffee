# миксин может подмешиваться в наследники класса Stock

# !!! Необходимое условие использования миксина - Коллекция должна имплементировать QueryableMixinInterface

_ = require 'lodash'

module.exports = (Module)->
  {
    ANY
    ASYNC

    ChainsMixin
  } = Module::

  Module.defineMixin (BaseClass) ->
    class BulkActionsStockMixin extends BaseClass
      @inheritProtected()

      cpmChains = Symbol.for '~getChains'

      unless @classMethods.action?
        @public @static action: Function,
          default: (nameDefinition, config)->
            [actionName] = Object.keys nameDefinition
            if nameDefinition.attr? and not config?
              @metaObject.addMetaData 'actions', nameDefinition.attr, nameDefinition
            else
              @metaObject.addMetaData 'actions', actionName, config
            @public arguments...
      unless @classMethods.chains?
        @include ChainsMixin

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


    BulkActionsStockMixin.initializeMixin()
