_             = require 'lodash'
inflect       = do require 'i'
statuses      = require 'statuses'

HTTP_NOT_FOUND    = statuses 'not found'
UNAUTHORIZED      = statuses 'unauthorized'
FORBIDDEN         = statuses 'forbidden'
UPGRADE_REQUIRED  = statuses 'upgrade required'

module.exports = (Module)->
  {
    ANY
    NILL
    APPLICATION_MEDIATOR
    HANDLER_RESULT
    DELAYED_JOBS_QUEUE
    RESQUE

    SimpleCommand
    ResourceInterface
    ConfigurableMixin
    ChainsMixin
    ContextInterface
  } = Module::

  class Resource extends SimpleCommand
    @inheritProtected()
    @implements ResourceInterface
    @include ConfigurableMixin
    @include ChainsMixin
    @module Module

    # @public entityName: String # Имя сущности должно быть установлено при объявлении дочернего класса

    # example of usage
    ###
    @initialHook 'checkApiVersion'
    @initialHook 'checkSession'
    @initialHook 'adminOnly', only: ['create'] # required checkSession before
    @initialHook 'checkOwner', only: ['detail', 'update', 'delete'] # required checkSession before

    @beforeHook 'beforeLimitedList', only: ['list']
    @beforeHook 'setOwnerId',       only: ['create']
    @beforeHook 'protectOwnerId',   only: ['update']
    @beforeHook 'protectSpaceId',   only: ['update']

    ###

    @public @async checkApiVersion: Function,
      default: (args...)->
        vVersion = @context.pathParams.v
        vCurrentVersion = @configs.version
        unless vCurrentVersion?
          throw new Error 'No `version` specified in the configuration'
        [vNeedVersion] = vCurrentVersion.match(/^\d{1,}[.]\d{1,}/) ? []
        unless vNeedVersion?
          throw new Error 'Incorrect `version` specified in the configuration'
        sendError = =>
          @context.throw UPGRADE_REQUIRED, "Upgrade: v#{vNeedVersion}"
        unless /^[v]\d{1,}[.]\d{1,}/.test vVersion
          sendError()
        unless new RegExp(vVersion).test "v#{vCurrentVersion}"
          sendError()
        yield return args

    @public @async setOwnerId: Function,
      default: (args...)->
        @recordBody.ownerId = @currentUser?.id ? null
        yield return args

    @public @async protectOwnerId: Function,
      default: (args...)->
        @recordBody = _.omit @recordBody, ['ownerId']
        yield return args

    @public @async setSpaceId: Function,
      default: (args...)->
        @recordBody.spaceId = @context.pathParams.space ? '_default'
        yield return args

    @public @async protectSpaceId: Function,
      default: (args...)->
        @recordBody = _.omit @recordBody, ['spaceId']
        yield return args

    @public @async beforeLimitedList: Function,
      default: (args...)->
        if @currentUser? and not @currentUser.isAdmin
          @query ?= {}
          @query.ownerId = @currentUser.id
        yield return args

    @public @async checkOwner: Function,
      default: (args...) ->
        unless @session?.uid? and @currentUser?
          @context.throw UNAUTHORIZED
          return
        if @currentUser.isAdmin
          return args
        unless (key = @context.pathParams[@keyName])?
          return args
        doc = yield @collection.find key
        unless doc?
          @context.throw HTTP_NOT_FOUND
        unless doc.ownerId
          return args
        if @currentUser.id isnt doc.ownerId
          @context.throw FORBIDDEN
          return
        yield return args

    @public @async requiredAuthorizationHeader: Function,
      default: (args...) ->
        { apiKey }        = @configs
        {
          authorization: authHeader
        } = @context.headers
        unless authHeader?
          @context.throw UNAUTHORIZED
        [..., key] = (/^Bearer\s+(.+)$/.exec authHeader) ? []
        unless key?
          @context.throw UNAUTHORIZED
        unless key is apiKey
          @context.throw UNAUTHORIZED
        yield return args

    @public @async adminOnly: Function,
      default: (args...) ->
        unless @session?.uid? and @currentUser?
          @context.throw UNAUTHORIZED
          return
        unless @currentUser.isAdmin
          @context.throw FORBIDDEN
          return
        yield return args

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

    @public context: ContextInterface

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

    @initialHook 'beforeActionHook'

    @beforeHook 'getQuery', only: ['list']
    @beforeHook 'getRecordId', only: ['detail', 'update', 'delete']
    @beforeHook 'getRecordBody', only: ['create', 'update']
    @beforeHook 'omitBody', only: ['create', 'update']
    @beforeHook 'beforeUpdate', only: ['update']

    @public beforeActionHook: Function,
      args: [Object]
      return: ANY
      default: (args...)->
        [@context] = args
        return args

    @public getQuery: Function,
      args: [Object]
      return: ANY
      default: (args...)->
        @query = JSON.parse @context.query['query'] ? "{}"
        return args

    @public getRecordId: Function,
      args: [Object]
      return: ANY
      default: (args...)->
        @recordId = @context.pathParams[@keyName]
        return args

    @public getRecordBody: Function,
      args: [Object]
      return: ANY
      default: (args...)->
        @recordBody = @context.request.body?[@itemEntityName]
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
        @recordBody.type = "#{moduleName}::#{name}"
        return args

    @public beforeUpdate: Function,
      args: [Object]
      return: ANY
      default: (args...)->
        @recordBody = Module::Utils.extend {}, @recordBody, id: @recordId
        return args

    @public @async doAction: Function, # для того, чтобы отдельная примесь могла переопределить этот метод и обернуть выполнение например в транзакцию
      args: [String, Module::ContextInterface]
      return: Module::ANY
      default: (action, context)->
        voResult = yield @[action]? context
        yield return voResult

    @public @async needsTransaction: Function,
      args: [String, Module::ContextInterface]
      return: Boolean
      default: (asAction, aoContext) ->
        yield return aoContext.method.toUpperCase() isnt 'GET'

    @public @async saveDelayeds: Function, # для того, чтобы сохранить все отложенные джобы
      args: [Module::ApplicationInterface]
      return: Module::NILL
      default: (app)->
        resque = app.facade.retrieveProxy RESQUE
        for delayed in yield resque.getDelayed()
          {queueName, scriptName, data, delay} = delayed
          queue = yield resque.get queueName ? DELAYED_JOBS_QUEUE
          yield queue.push scriptName, data, delay
        yield return

    @public @async execute: Function,
      args: [Module::NotificationInterface]
      return: Module::NILL
      default: (aoNotification)->
        resourceName = aoNotification.getName()
        voBody = aoNotification.getBody()
        action = aoNotification.getType()
        service = @facade.retrieveMediator APPLICATION_MEDIATOR
          .getViewComponent()
        try
          if service.context?
            voResult =
              result: yield @doAction action, voBody.context
              resource: @
          else
            app = @Module::MainApplication.new Module::LIGHTWEIGHT
            voResult = yield app.execute resourceName, voBody, action
            yield @saveDelayeds app
            app.finish()
        catch err
          voResult =
            error: err
            resource: @
        @sendNotification HANDLER_RESULT, voResult, voBody.reverse
        yield return


  Resource.initialize()
