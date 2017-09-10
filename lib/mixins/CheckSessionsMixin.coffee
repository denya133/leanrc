statuses          = require 'statuses'
UNAUTHORIZED      = statuses 'unauthorized'

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

    Resource
    RecordInterface
  } = Module::

  Module.defineMixin Resource, (BaseClass) ->
    class CheckSessionsMixin extends BaseClass
      @inheritProtected()

      @public session: RecordInterface
      @public currentUser: RecordInterface

      @public checkHeader: Function,
        default: ->
          { apiKey, clientKey } = @configs
          {
            authorization: authHeader
          } = @context.headers
          return no   unless authHeader?
          [..., key] = (/^Bearer\s+(.+)$/.exec authHeader) ? []
          return no   unless key?
          return apiKey is key or clientKey is key

      @public @async makeSession: Function,
        default: ->
          SessionsCollection = @facade.retrieveProxy SESSIONS
          if @checkHeader()
            session = SessionsCollection.build {uid: 'admin'}
          else if (sessionCookie = @context.cookies.get @configs.sessionCookie)?
            session = yield SessionsCollection.find sessionCookie
          unless session?
            session = SessionsCollection.build()
          @session = session
          yield return

      @public @async checkSession: Function,
        default: (args...)->
          yield @makeSession()
          unless @session?.uid?
            @context.throw UNAUTHORIZED
            return
          UsersCollection = @facade.retrieveProxy USERS
          currentUser = yield UsersCollection.find @session.uid
          unless currentUser?.verified
            @context.throw UNAUTHORIZED, 'Unverified'
            return
          @currentUser = currentUser
          yield return args


    CheckSessionsMixin.initializeMixin()
