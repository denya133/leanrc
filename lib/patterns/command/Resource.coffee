semver        = require 'semver'


module.exports = (Module)->
  {
    ANY
    NILL
    APPLICATION_MEDIATOR
    HANDLER_RESULT
    DELAYED_JOBS_QUEUE
    RESQUE
    MIGRATIONS

    SimpleCommand
    ResourceInterface
    ConfigurableMixin
    ChainsMixin
    ContextInterface

    Utils: { _, inflect, statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  UNAUTHORIZED      = statuses 'unauthorized'
  FORBIDDEN         = statuses 'forbidden'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  class Resource extends SimpleCommand
    @inheritProtected()
    # @implements ResourceInterface
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

    @beforeHook 'filterOwnerByCurrentUser', only: ['list']
    @beforeHook 'setOwnerId',       only: ['create']
    @beforeHook 'protectOwnerId',   only: ['update']

    ###

    @public needsLimitation: Boolean,
      default: yes

    @public @async checkApiVersion: Function,
      default: (args...)->
        vVersion = @context.pathParams.v
        vCurrentVersion = @configs.version
        unless vCurrentVersion?
          throw new Error 'No `version` specified in the configuration'
        [vNeedVersion] = vCurrentVersion.match(/^\d{1,}[.]\d{1,}/) ? []
        unless vNeedVersion?
          throw new Error 'Incorrect `version` specified in the configuration'
        unless semver.satisfies vCurrentVersion, vVersion
          @context.throw UPGRADE_REQUIRED, "Upgrade: v#{vCurrentVersion}"
        yield return args

    @public @async setOwnerId: Function,
      default: (args...)->
        @recordBody.ownerId = @currentUser?.id ? null
        yield return args

    @public @async protectOwnerId: Function,
      default: (args...)->
        @recordBody = _.omit @recordBody, ['ownerId']
        yield return args

    @public @async filterOwnerByCurrentUser: Function,
      default: (args...)->
        if @currentUser? and not @currentUser.isAdmin
          @listQuery ?= {}
        if @listQuery.$filter?
          @listQuery.$filter = $and: [
            @listQuery.$filter
          ,
            '@doc.ownerId': $eq: @currentUser.id
          ]
        else
          @listQuery.$filter = '@doc.ownerId': $eq: @currentUser.id
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

    @public @async checkExistence: Function,
      default: (args...) ->
        unless @recordId?
          @context.throw HTTP_NOT_FOUND
        unless yield @collection.includes @recordId
          @context.throw HTTP_NOT_FOUND
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

    @public @async checkSchemaVersion: Function,
      default: (args...)->
        voMigrations = @facade.retrieveProxy MIGRATIONS
        [..., lastMigration] = @Module::MIGRATION_NAMES
        includes = yield voMigrations.includes lastMigration
        if includes
          yield return args
        else
          throw new Error 'Code schema version is not equal current DB version'
          yield return
        return args

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

    @public listQuery: Object
    @public recordId: String
    @public recordBody: Object

    @public @static actions: Object,
      get: -> @metaObject.getGroup 'actions'

    @public @static action: Function,
      default: (nameDefinition, config)->
        t1 = Date.now()
        [actionName] = Object.keys nameDefinition
        if nameDefinition.attr? and not config?
          @metaObject.addMetaData 'actions', nameDefinition.attr, nameDefinition
        else
          @metaObject.addMetaData 'actions', actionName, config
        @____dt += Date.now() - t1
        @public arguments...

    @action @async list: Function,
      default: ->
        vlItems = yield (yield @collection.takeAll()).toArray()
        return {
          meta:
            pagination:
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
        @context.status = 204
        yield return


    # ------------ Chains definitions ---------
    @chains [
      'list', 'detail', 'create', 'update', 'delete'
    ]

    @initialHook 'beforeActionHook'

    @beforeHook 'getQuery', only: ['list']
    @beforeHook 'getRecordId', only: ['detail', 'update', 'delete']
    @beforeHook 'checkExistence', only: ['detail', 'update', 'delete']
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
        @listQuery = JSON.parse @context.query['query'] ? "{}"
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

    @public @async doAction: Function,
      args: [String, Module::ContextInterface]
      return: Module::ANY
      default: (action, context)->
        voResult = yield @[action]? context
        yield @saveDelayeds()
        yield return voResult

    @public @async writeTransaction: Function,
      args: [String, Module::ContextInterface]
      return: Boolean
      default: (asAction, aoContext) ->
        yield return aoContext.method.toUpperCase() isnt 'GET'

    @public @async saveDelayeds: Function,
      args: [Module::ApplicationInterface]
      return: Module::NILL
      default: ->
        resque = @facade.retrieveProxy RESQUE
        for delayed in yield resque.getDelayed()
          {queueName, scriptName, data, delay} = delayed
          queue = yield resque.get queueName ? DELAYED_JOBS_QUEUE
          yield queue.push scriptName, data, delay
        yield return

    @public @async execute: Function,
      args: [Module::NotificationInterface]
      return: Module::NILL
      default: (aoNotification)->
        { ERROR, DEBUG, LEVELS, SEND_TO_LOG } = Module::LogMessage
        resourceName = aoNotification.getName()
        voBody = aoNotification.getBody()
        action = aoNotification.getType()
        service = @facade.retrieveMediator APPLICATION_MEDIATOR
          .getViewComponent()
        try
          if service.context?
            @sendNotification SEND_TO_LOG, '>>>>>>>>>>>>>> EXECUTION START', LEVELS[DEBUG]
            voResult =
              result: yield @doAction action, voBody.context
              resource: @
            @sendNotification SEND_TO_LOG, '>>>>>>>>>>>>>> EXECUTION END', LEVELS[DEBUG]
          else
            @sendNotification SEND_TO_LOG, '>>>>>>>>>> LIGHTWEIGHT CREATE', LEVELS[DEBUG]
            t1 = Date.now()
            app = @Module::MainApplication.new Module::LIGHTWEIGHT
            @sendNotification SEND_TO_LOG, ">>>>>>>>>> LIGHTWEIGHT START after #{Date.now() - t1}", LEVELS[DEBUG]
            voResult = yield app.execute resourceName, voBody, action
            @sendNotification SEND_TO_LOG, '>>>>>>>>>> LIGHTWEIGHT END', LEVELS[DEBUG]
            t2 = Date.now()
            app.finish()
            @sendNotification SEND_TO_LOG, ">>>>>>>>>> LIGHTWEIGHT DESTROYED after #{Date.now() - t2}", LEVELS[DEBUG]
        catch err
          voResult =
            error: err
            resource: @
        @sendNotification HANDLER_RESULT, voResult, voBody.reverse
        yield return


  Resource.initialize()
