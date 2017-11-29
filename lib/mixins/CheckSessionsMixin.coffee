

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

    Utils: { statuses }
  } = Module::

  UNAUTHORIZED      = statuses 'unauthorized'

  Module.defineMixin Resource, (BaseClass) ->
    class CheckSessionsMixin extends BaseClass
      @inheritProtected()

      @public session: RecordInterface
      @public currentUser: RecordInterface

      @public @async makeSession: Function,
        default: ->
          SessionsCollection = @facade.retrieveProxy SESSIONS
          if (sessionCookie = @context.cookies.get @configs.sessionCookie)?
            session = yield (yield SessionsCollection.findBy
              "@doc.id": sessionCookie
            ).first()
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
