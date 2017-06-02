_                 = require 'lodash'
statuses          = require 'statuses'
UNAUTHORIZED      = statuses 'unauthorized'
FORBIDDEN         = statuses 'forbidden'

###
example of usage

```coffee

module.exports = (Module)->
  {
    Resource
    BodyParseMixin
    CheckPermissionsMixin
  } = Module::

  class UsersResource extends Resource
    @inheritProtected()
    @include BodyParseMixin
    @include CheckPermissionsMixin
    @module Module

    @public entityName: String,
      default: 'user'

    @initialHook 'checkPermission', only: [
      'list', 'detail', 'update'
    ]
    @initialHook 'parseBody', only: ['create', 'update']


  UsersResource.initialize()


```
###


module.exports = (Module)->
  {
    SPACES
    ROLES

    Resource
    RecordInterface
    Utils
  } = Module::
  { forEach } = Utils

  Module.defineMixin Resource, (BaseClass) ->
    class CheckPermissionsMixin extends BaseClass
      @inheritProtected()

      @public spaces: Array
      @public space: RecordInterface

      ipoCheckOwner = @private @async checkOwner: Function,
        default: (spaceId, userId)->
          SpacesCollection = @facade.retrieveProxy SPACES
          space = yield SpacesCollection.find spaceId
          yield return space.ownerId is userId

      ipoCheckRole = @private @async checkRole: Function,
        default: (spaceId, userId, action)->
          RolesCollection = @facade.retrieveProxy ROLES
          role = yield (yield RolesCollection.findBy {spaceId, userId}).first()
          if role?.rules?['system']?['administrator']
            yield return yes
          else if role?.rules?['moderator']?[@constructor.name]
            yield return yes
          else if role?.rules?[@constructor.name]?[action]
            yield return yes
          else
            yield return no

      ipoCheckPermission = @private @async checkPermission: Function,
        default: (space, chainName)->
          if yield @[ipoCheckOwner] space, @currentUser.id
            yield return yes
          else if yield @[ipoCheckRole] space, @currentUser.id, chainName
            yield return yes
          else
            @context.throw FORBIDDEN, "Current user has not access"
            yield return

      @public @async checkPermission: Function,
        default: checkPermission = (args...)->
          if @currentUser.role is 'admin'
            yield return args 
          space = @context.pathParams['space'] ? '_default'
          if checkPermission.wrapper.chainName is 'list'
            spaces = space.split '-'
            unless _.isArray spaces
              spaces = [spaces]
            yield from forEach spaces, (item)=>
              yield @[ipoCheckPermission] item, 'list'
            @spaces = spaces
          else
            yield @[ipoCheckPermission] space, checkPermission.wrapper.chainName
            @space = space
          yield return args


    CheckPermissionsMixin.initializeMixin()
