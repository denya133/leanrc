# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

module.exports = (Module)->
  {
    SPACES
    ROLES
    PromiseT, PointerT
    FuncG, MaybeG
    Resource, Mixin
    Utils: { _, statuses, co }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  UNAUTHORIZED      = statuses 'unauthorized'
  FORBIDDEN         = statuses 'forbidden'

  Module.defineMixin Mixin 'SharingResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @public namespace: String,
        default: 'sharing'

      @public currentSpaceId: String,
        get: -> @context.pathParams.space

      @public currentSpace: PromiseT,
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

      ipoCheckOwner = PointerT @private @async checkOwner: FuncG(String, Boolean),
        default: (userId)->
          yield return @currentSpaceId in @session.ownSpaces

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
