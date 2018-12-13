

module.exports = (Module)->
  {
    SPACES
    ROLES

    Resource
    PromiseInterface

    Utils: { _, statuses, co }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  UNAUTHORIZED      = statuses 'unauthorized'
  FORBIDDEN         = statuses 'forbidden'

  Module.defineMixin 'SharingResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @public namespace: String,
        default: 'sharing'

      @public currentSpaceId: String,
        get: -> @context.pathParams.space

      # @public spaces: Array
      @public currentSpace: PromiseInterface,
        get: co.wrap ->
          return yield @facade.retrieveProxy(SPACES).find @currentSpaceId

      @beforeHook 'limitBySpace',   only: ['list']
      @beforeHook 'setSpaces',      only: ['create']
      @beforeHook 'setOwnerId',     only: ['create']
      @beforeHook 'protectSpaces',  only: ['update']
      @beforeHook 'protectOwnerId', only: ['update']

      @public @async limitBySpace: Function,
        default: (args...)->
          @listQuery ?= {}
          if @listQuery.$filter?
            @listQuery.$filter = $and: [
              @listQuery.$filter
            ,
              '@doc.spaces': $all: [@currentSpaceId]
            ]
          else
            @listQuery.$filter = '@doc.spaces': $all: [@currentSpaceId]
          yield return args

      @public @async checkExistence: Function,
        default: (args...)->
          unless @recordId?
            @context.throw HTTP_NOT_FOUND
          unless (yield @collection.exists
            '@doc.id': $eq: @recordId
            '@doc.spaces': $all: [@currentSpaceId]
          )
            @context.throw HTTP_NOT_FOUND
          yield return args

      @public @async setOwnerId: Function,
        default: (args...)->
          @recordBody.ownerId = 'system'
          yield return args

      @public @async setSpaces: Function,
        default: (args...)->
          @recordBody.spaces ?= []
          unless _.includes @recordBody.spaces, '_internal'
            @recordBody.spaces.push '_internal'
          unless _.includes @recordBody.spaces, @session.userSpaceId
            @recordBody.spaces.push @session.userSpaceId
          unless _.includes @recordBody.spaces, @currentSpaceId
            @recordBody.spaces.push @currentSpaceId
          yield return args

      @public @async protectSpaces: Function,
        default: (args...)->
          @recordBody = _.omit @recordBody, ['spaces']
          yield return args

      ipoCheckOwner = @private @async checkOwner: Function,
        default: (userId)->
          yield return @currentSpaceId in @session.ownSpaces

      ipoCheckRole = @private @async checkRole: Function,
        default: (spaceId, userId, action)->
          RolesCollection = @facade.retrieveProxy ROLES
          role = yield (yield RolesCollection.findBy(
            spaceUser: {spaceId, userId}
          )).first()
          resourceKey = "#{@Module.name}::#{@constructor.name}"
          unless role?
            yield return no
          {rules} = role
          if not rules? and role.getRules?
            rules = yield role.getRules()
          if rules?['moderator']?[resourceKey]
            yield return yes
          else if rules?[resourceKey]?[action]
            yield return yes
          else
            yield return no

      ipoCheckPermission = @private @async checkPermission: Function,
        default: (spaceId, chainName)->
          if yield @[ipoCheckOwner] @session.uid
            yield return yes
          else if yield @[ipoCheckRole] spaceId, @session.uid, chainName
            yield return yes
          else
            @context.throw FORBIDDEN, "Current user has no access"
            yield return

      @public @async checkPermission: Function,
        default: checkPermission = (args...)->
          {chainName} = checkPermission.wrapper
          # SpacesCollection = @facade.retrieveProxy SPACES
          # try
          #   @space = yield SpacesCollection.find spaceId
          # unless @space?
          #   @context.throw FORBIDDEN, "Current user has no access"
          if @session.userIsAdmin
            yield return args
          yield @[ipoCheckPermission] @currentSpaceId, chainName
          yield return args


      @initializeMixin()
