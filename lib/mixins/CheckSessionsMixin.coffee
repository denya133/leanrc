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

###
example of usage

```coffee

module.exports = (Module)->
  {
    Resource
    BodyParseMixin
    CheckSessionsMixin
  } = Module::

  class UsersResource extends Resource
    @inheritProtected()
    @include BodyParseMixin
    @include CheckSessionsMixin
    @module Module

    @public entityName: String,
      default: 'user'

    @initialHook 'checkSession', only: [
      'list', 'detail', 'update'
    ]
    @initialHook 'parseBody', only: ['create', 'update']
    @initialHook 'checkOwner', only: ['update']


  UsersResource.initialize()


```
###

module.exports = (Module)->
  {
    SESSIONS
    USERS
    PromiseT
    RecordInterface
    Resource, Mixin
    Utils: { statuses, co }
  } = Module::

  UNAUTHORIZED      = statuses 'unauthorized'

  Module.defineMixin Mixin 'CheckSessionsMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @public session: RecordInterface
      @public currentUser: PromiseT,
        get: co.wrap ->
          return yield @facade.retrieveProxy(USERS).find @session.uid

      @public @async makeSession: Function,
        default: ->
          SessionsCollection = @facade.retrieveProxy SESSIONS
          if (sessionCookie = @context.cookies.get @configs.sessionCookie)?
            session = yield (yield SessionsCollection.findBy(
              "@doc.id": sessionCookie
            )).first()
          if session?
            unless session.userSpaceId?
              session = yield (
                SessionsCollection.calcComputedsForOne?(session) ? session
              )
          else
            session = yield SessionsCollection.build({})
          @context.session = session
          @session = session
          yield return

      @public @async checkSession: Function,
        default: (args...)->
          yield @makeSession()
          unless @session.uid?
            @context.throw UNAUTHORIZED
            return
          # UsersCollection = @facade.retrieveProxy USERS
          # currentUser = yield UsersCollection.find @session.uid
          unless @session.userVerified
            @context.throw UNAUTHORIZED, 'Unverified'
            return
          # @currentUser = currentUser
          yield return args


      @initializeMixin()
