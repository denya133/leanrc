

module.exports = (Module)->
  {
    SPACES
    ROLES

    Resource
    RecordInterface

    Utils: { _, statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  UNAUTHORIZED      = statuses 'unauthorized'
  FORBIDDEN         = statuses 'forbidden'

  Module.defineMixin Resource, (BaseClass) ->
    class SharingResourceMixin extends BaseClass
      @inheritProtected()

      @public spaces: Array
      @public space: RecordInterface

      @beforeHook 'limitBySpace',   only: ['list']
      @beforeHook 'setSpaces',      only: ['create']
      @beforeHook 'setOwnerId',     only: ['create']
      @beforeHook 'protectSpaces',  only: ['update']
      @beforeHook 'protectOwnerId', only: ['update']

      @public @async limitBySpace: Function,
        default: (args...)->
          @listQuery ?= {}
          currentSpace = @context.pathParams.space
          if @listQuery.$filter?
            @listQuery.$filter = $and: [
              @listQuery.$filter
            ,
              '@doc.spaces': $all: [currentSpace]
            ]
          else
            @listQuery.$filter = '@doc.spaces': $all: [currentSpace]
          yield return args

      @public @async checkExistence: Function,
        default: (args...)->
          currentSpace = @context.pathParams.space
          unless @recordId?
            @context.throw HTTP_NOT_FOUND
          unless (yield @collection.exists
            '@doc.id': $eq: @recordId
            '@doc.spaces': $all: [currentSpace]
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
          unless _.includes @recordBody.spaces, @currentUser.spaceId
            @recordBody.spaces.push @currentUser.spaceId
          currentSpace = @context.pathParams.space
          unless _.includes @recordBody.spaces, currentSpace
            @recordBody.spaces.push currentSpace
          yield return args

      @public @async protectSpaces: Function,
        default: (args...)->
          @recordBody = _.omit @recordBody, ['spaces']
          yield return args

      ipoCheckOwner = @private @async checkOwner: Function,
        default: (userId)->
          yield return @space?.ownerId is userId

      ipoCheckRole = @private @async checkRole: Function,
        default: (spaceId, userId, action)->
          RolesCollection = @facade.retrieveProxy ROLES
          role = yield (yield RolesCollection.findBy
            '@doc.spaceId': $eq: spaceId
            userId: userId
          ).first()
          resourceKey = "#{@Module.name}::#{@constructor.name}"
          if role?
            {rules} = role
            if not rules? and role.getRules?
              rules = yield role.getRules()
          else if rules?['moderator']?[resourceKey]
            yield return yes
          else if rules?[resourceKey]?[action]
            yield return yes
          else
            yield return no

      ipoCheckPermission = @private @async checkPermission: Function,
        default: (spaceId, chainName)->
          if yield @[ipoCheckOwner] @currentUser?.id
            yield return yes
          else if yield @[ipoCheckRole] spaceId, @currentUser?.id, chainName
            yield return yes
          else
            @context.throw FORBIDDEN, "Current user has no access"
            yield return

      @public @async checkPermission: Function,
        default: checkPermission = (args...)->
          space = @context.pathParams['space']
          {chainName} = checkPermission.wrapper
          SpacesCollection = @facade.retrieveProxy SPACES
          @space = yield SpacesCollection.find space
          if @currentUser.isAdmin
            yield return args
          yield @[ipoCheckPermission] space, chainName
          yield return args


    SharingResourceMixin.initializeMixin()
