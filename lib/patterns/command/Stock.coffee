_             = require 'lodash'
inflect       = do require 'i'


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
        vlItems = yield (yield @collection.takeAll()).toArray()
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


    # ------------ Chains definitions ---------
    @chains [
      'list', 'detail', 'create', 'update', 'delete'
    ]

    @beforeHook 'beforeActionHook'

    @beforeHook 'parsePathParams', only: ['detail', 'update', 'delete']
    @beforeHook 'parseBody', only: ['create', 'update']
    @beforeHook 'omitBody', only: ['create', 'update']
    @beforeHook 'beforeUpdate', only: ['update']

    @public beforeActionHook: Function,
      args: [Object]
      return: NILL
      default: (args...)->
        [{ @queryParams, @pathParams, @currentUserId, @headers, @body }] = args
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

    @public omitBody: Function,
      args: [Object]
      return: ANY
      default: (args...)->
        @recordBody = _.omit @recordBody, [
          '_id', '_rev', 'rev', 'type', '_type'
          '_owner', '_space',
          '_from', '_to'
        ]
        moduleName = @collection.delegate.moduleName()
        name = @collection.delegate.name
        @recordBody._type = "#{moduleName}::#{name}"
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
