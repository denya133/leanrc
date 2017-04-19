inflect = do require 'i'
# по сути здесь надо повторить (скопипастить) код из FoxxMC::Controller

RC = require 'RC'
{ANY, NILL} = RC::


module.exports = (LeanRC)->
  class LeanRC::Stock extends LeanRC::SimpleCommand
    @inheritProtected()
    @include RC::ChainsMixin
    @implements LeanRC::StockInterface

    @Module: LeanRC

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

    @public collection: LeanRC::CollectionInterface,
      get: ->
        @facade.retrieveProxy @collectionName

    @public queryParams: Object
    @public pathPatams: Object
    @public currentUserId: String
    @public headers: Object
    @public body: Object

    @public query: Object
    @public recordId: String
    @public recordBody: Object

    @public @static actions: Object,
      default: {}
      get: (__actions)->
        fromSuper = if @__super__?
          @__super__.constructor.actions
        __actions[@name] ?= do =>
          RC::Utils.extend []
          , (fromSuper ? [])
          , (@["_#{@name}_actions"] ? [])
        __actions[@name]

    @public @static action: Function,
      default: (nameDefinition, config)->
        [actionName] = Object.keys nameDefinition
        @["_#{@name}_actions"] ?= []
        @["_#{@name}_actions"].push actionName
        @public arguments...

    @action @async list: Function,
      default: ->
        vlItems = (yield @collection.query @query).toArray()
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
        cursor.forEach (aoRecord)-> yield aoRecord.updateAttributes @recordBody
        return yes

    @action @async bulkPatch: Function,
      default: ->
        cursor = yield @collection.query @query
        cursor.forEach (aoRecord)-> yield aoRecord.updateAttributes @recordBody
        return yes

    @action @async bulkDelete: Function,
      default: ->
        cursor = yield @collection.query @query
        cursor.forEach (aoRecord)-> yield aoRecord.destroy()
        return yes


    # ------------ Chains definitions ---------
    @chains [
      'list', 'detail', 'create', 'update', 'delete'
      'bulkUpdate', 'bulkPatch', 'bulkDelete'
    ]

    @beforeHook 'beforeAction'

    @beforeHook 'parseQuery', only: ['list', 'bulkUpdate', 'bulkPatch', 'bulkDelete']
    @beforeHook 'parsePathParams', only: ['detail', 'update', 'delete']
    @beforeHook 'parseBody', only: ['create', 'bulkUpdate', 'bulkPatch']
    @beforeHook 'beforeUpdate', only: ['update']

    @public beforeAction: Function,
      args: [Object]
      return: NILL
      default: (args...)->
        [{queryParams, pathPatams, currentUserId, headers, body }] = args
        {
          @queryParams, @pathPatams, @currentUserId, @headers, @body
        } = {queryParams, pathPatams, currentUserId, headers, body }
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
        @recordBody = RC::Utils.extend {}, @recordBody, id: @recordId
        return args

    @public execute: Function,
      default: (aoNotification)->
        RC::Utils.co =>
          voBody = aoNotification.getBody()
          voResult = yield @[aoNotification.getType()]? voBody
          @sendNotification LeanRC::HANDLER_RESULT, voResult, voBody.reverse
        return


  return LeanRC::Stock.initialize()
