inflect = do require 'i'
# по сути здесь надо повторить (скопипастить) код из FoxxMC::Controller


module.exports = (Module)->
  {ANY, NILL} = Module::

  class Stock extends Module::SimpleCommand
    @inheritProtected()
    @implements Module::StockInterface
    @include Module::ConfigurableMixin
    @include Module::ChainsMixin
    @module Module

    # @public entityName: String # Имя сущности должно быть установлено при объявлении дочернего класса

    @public keyName: String,
      get: ->
        inflect.singularize inflect.underscore @entityName

    @public itemEntityName: String,
      get: ->
        inflect.singularize inflect.underscore @entityName

    @public listEntityName: String,
      get: ->
        inflect.pluralize inflect.underscore @entityName

    @public collectionName: String,
      get: ->
        "#{inflect.pluralize inflect.camelize @entityName}Collection"

    @public collection: Module::CollectionInterface,
      get: ->
        @facade.retrieveProxy @collectionName

    @public queryParams: Object
    @public pathParams: Object
    @public currentUserId: String
    @public headers: Object
    @public body: Object

    @public query: Object
    @public recordId: String
    @public recordBody: Object

    @public @static actions: Object,
      get: -> @metaObject.getGroup 'actions'

    @public @static action: Function,
      default: (nameDefinition, config)->
        [actionName] = Object.keys nameDefinition
        if nameDefinition.attr? and not config?
          @metaObject.addMetaData 'actions', nameDefinition.attr, nameDefinition
        else
          @metaObject.addMetaData 'actions', actionName, config
        @public arguments...

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

    @action @async detail: Function,
      default: ->
        yield @collection.find @recordId

    @action @async create: Function,
      default: ->
        yield @collection.create @recordBody

    @action @async update: Function,
      default: ->
        yield @collection.update @recordId, @recordBody

    @action @async delete: Function,
      default: ->
        yield @collection.delete @recordId

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
      'list', 'detail', 'create', 'update', 'delete'
      'bulkUpdate', 'bulkPatch', 'bulkDelete'
    ]

    @beforeHook 'beforeActionHook'

    @beforeHook 'parseQuery', only: ['list', 'bulkUpdate', 'bulkPatch', 'bulkDelete']
    @beforeHook 'parsePathParams', only: ['detail', 'update', 'delete']
    @beforeHook 'parseBody', only: ['create', 'update', 'bulkUpdate', 'bulkPatch']
    @beforeHook 'beforeUpdate', only: ['update']

    @public beforeActionHook: Function,
      args: [Object]
      return: NILL
      default: (args...)->
        [{ @queryParams, @pathParams, @currentUserId, @headers, @body }] = args
        return args

    @public parseQuery: Function,
      args: [Object]
      return: ANY
      default: (args...)->
        @query = JSON.parse @queryParams['query']
        return args

    @public parsePathParams: Function,
      args: [Object]
      return: ANY
      default: (args...)->
        @recordId = @pathParams[@keyName]
        return args

    @public parseBody: Function,
      args: [Object]
      return: ANY
      default: (args...)->
        @recordBody = @body?[@itemEntityName]
        return args

    @public beforeUpdate: Function,
      args: [Object]
      return: ANY
      default: (args...)->
        @recordBody = Module::Utils.extend {}, @recordBody, id: @recordId
        return args

    @public @async execute: Function,
      args: [Module::NotificationInterface]
      return: Module::NILL
      default: (aoNotification)->
        voBody = aoNotification.getBody()
        voResult = yield @[aoNotification.getType()]? voBody
        @sendNotification Module::HANDLER_RESULT, voResult, voBody.reverse
        yield return


  Stock.initialize()
