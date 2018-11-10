

module.exports = (Module)->
  {
    SPACES
    ROLES
    PointerT, PromiseT
    FuncG, MaybeG
    Resource, Mixin
    Utils: { _, statuses, co }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  UNAUTHORIZED      = statuses 'unauthorized'
  FORBIDDEN         = statuses 'forbidden'

  Module.defineMixin Mixin 'AdminingResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @public currentSpace: PromiseT,
        get: co.wrap ->
          return yield @facade.retrieveProxy(SPACES).find '_internal'

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
              '@doc.spaces': $all: ['_internal']
            ]
          else
            @listQuery.$filter = '@doc.spaces': $all: ['_internal']
          yield return args

      @public @async checkExistence: Function,
        default: (args...)->
          unless @recordId?
            @context.throw HTTP_NOT_FOUND
          unless (yield @collection.exists(
            '@doc.id': $eq: @recordId
            '@doc.spaces': $all: ['_internal']
          ))
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
          # NOTE: временно закоментировал, т.к. появилось понимание, что контент создаваемый через админку не должен быть "частно" доступен у человека, который его создал - НО это надо обсуждать!
          # unless _.includes @recordBody.spaces, @session.userSpaceId
          #   @recordBody.spaces.push @session.userSpaceId
          # TODO: если примем решение что в урле будет захардкожен _internal, то в следующих 3-х строчках нет никакого смысла.
          currentSpace = @context.pathParams.space
          unless _.includes @recordBody.spaces, currentSpace
            @recordBody.spaces.push currentSpace
          yield return args

      @public @async protectSpaces: Function,
        default: (args...)->
          @recordBody = _.omit @recordBody, ['spaces']
          yield return args

      ipoCheckRole = PointerT @private @async checkRole: FuncG([String, String, String], Boolean),
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

      ipoCheckPermission = PointerT @private @async checkPermission: FuncG([String, String], MaybeG Boolean),
        default: (space, chainName)->
          if yield @[ipoCheckRole] space, @session.uid, chainName
            yield return yes
          else
            @context.throw FORBIDDEN, "Current user has no access"
            yield return

      @public @async checkPermission: Function,
        default: checkPermission = (args...)->
          # SpacesCollection = @facade.retrieveProxy SPACES
          # try
          #   @space = yield SpacesCollection.find '_internal'
          # unless @space?
          #   @context.throw HTTP_NOT_FOUND, "Space with id: _internal not found"
          if @session.userIsAdmin
            yield return args
          {chainName} = checkPermission.wrapper
          yield @[ipoCheckPermission] '_internal', chainName
          yield return args


      @initializeMixin()
