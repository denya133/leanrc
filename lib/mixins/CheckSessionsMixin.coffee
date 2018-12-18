

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
