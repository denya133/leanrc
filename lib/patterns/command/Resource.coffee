_             = require 'lodash'
inflect       = do require 'i'

# TODO: Надо изготовить bodyParseMixin - который будет распарсивать тело в ctx - за основу можно взять https://github.com/cojs/co-body
# TODO: Надо изготовить cookieParseMixin - который будет распарсивать куки.

module.exports = (Module)->
  {
    ANY
    NILL

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

    # TODO: надо будет в будущем решить вопрос где должны быть эти вещи:
    ###

    @initialHook 'initializeDependencies'
    @initialHook 'checkApiVersion'

    @beforeHook 'permitBody',       only: ['create', 'update']
    @beforeHook 'setOwnerId',       only: ['create']
    @beforeHook 'protectOwnerId',   only: ['update']
    @beforeHook 'protectSpaceId',   only: ['update']

    initializeDependencies: (args...)->
      console.log '???? test @Module', @Module
      @constructor.Module.initializeModules()
      args

    checkApiVersion: (args...)->
      vVersion = @req.pathParams.v
      vCurrentVersion = @constructor.Module.context.manifest.version
      [vNeedVersion] = vCurrentVersion.match /^\d{1,}[.]\d{1,}/
      sendError = =>
        @res.throw UPGRADE_REQUIRED, "Upgrade: v#{vNeedVersion}"
      unless /^[v]\d{1,}[.]\d{1,}/.test vVersion
        sendError()
      unless new RegExp(vVersion).test "v#{vCurrentVersion}"
        sendError()
      args

    setOwnerId: ->
      @isValid()
      @body.ownerId = @currentUser?._key ? null
      return

    protectOwnerId: ->
      @isValid()
      @body = _.omit @body, ['ownerId']
      return

    protectSpaceId: ->
      @isValid()
      @body = _.omit @body, ['spaceId']
      return

    beforeLimitedList: (query = {}) ->
      { currentUser } = @req
      if currentUser? and not currentUser.isAdmin
        query.ownerId = currentUser._key
      {@query, @currentUser} = {query, currentUser}
      return

    _checkHeader: (req) ->
      { apiKey }        = @Module.context.configuration
      {
        authorization: authHeader
      } = req.headers
      return no   unless authHeader?
      [..., key] = (/^Bearer\s+(.+)$/.exec authHeader) ? []
      return no   unless key?
      encryptedApiKey = crypto.sha512 apiKey
      crypto.constantEquals encryptedApiKey, key

    checkSession: (args...)->
      # Must be implemented CheckSessionMixin and inclede in all controllers
      @req.currentUser = {}
      args

    checkOwner: @method [], ->
      @isValid()
      read: [ @Model.collectionName() ]
    , (args...) ->
      @isValid()
      unless @req.session?.uid? and @req.currentUser?
        @res.throw UNAUTHORIZED
        return
      if @req.currentUser.isAdmin
        return args
      unless (key = @req.pathParams[@constructor.keyName()])?
        return args
      doc = @Model.find key, @req.currentUser
      unless doc?
        @res.throw HTTP_NOT_FOUND
      unless doc._owner
        return args
      if @req.currentUser._key isnt doc._owner
        @res.throw FORBIDDEN
        return
      args

    adminOnly: (args...) ->
      unless @req.session?.uid? and @req.currentUser?
        @res.throw UNAUTHORIZED
        return
      unless @req.currentUser.isAdmin
        @res.throw FORBIDDEN
        return
      args

    ###

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
    # @public queryParams: Object
    # @public pathParams: Object
    @public currentUserId: String
    # @public headers: Object
    # @public body: Object

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

    @beforeHook 'getRecordId', only: ['detail', 'update', 'delete']
    @beforeHook 'getRecordBody', only: ['create', 'update']
    @beforeHook 'omitBody', only: ['create', 'update']
    @beforeHook 'beforeUpdate', only: ['update']

    @public beforeActionHook: Function,
      args: [Object]
      return: NILL
      default: (args...)->
        console.log '>>>>>222 IN beforeActionHook', args
        [@context] = args
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
        console.log '>>>>> 111', @context, @context?.request
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

    @public @async execute: Function,
      args: [Module::NotificationInterface]
      return: Module::NILL
      default: (aoNotification)->
        voBody = aoNotification.getBody()
        console.log '>>>>>3333', voBody
        voResult = yield @[aoNotification.getType()]? voBody.context
        @sendNotification Module::HANDLER_RESULT, voResult, voBody.reverse
        yield return


  Resource.initialize()
