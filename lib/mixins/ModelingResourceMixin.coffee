_             = require 'lodash'
statuses      = require 'statuses'

HTTP_NOT_FOUND    = statuses 'not found'
UNAUTHORIZED      = statuses 'unauthorized'


module.exports = (Module)->
  {
    SESSIONS
    USERS

    Resource
    RecordInterface
  } = Module::

  Module.defineMixin Resource, (BaseClass) ->
    class ModelingResourceMixin extends BaseClass
      @inheritProtected()

      @public needsLimitation: Boolean,
        default: no

      @public session: RecordInterface
      @public currentUser: RecordInterface

      @public checkHeader: Function,
        default: ->
          { apiKey } = @configs
          {
            authorization: authHeader
          } = @context.headers
          return no   unless authHeader?
          [..., key] = (/^Bearer\s+(.+)$/.exec authHeader) ? []
          return no   unless key?
          return apiKey is key

      @public @async makeSession: Function,
        default: ->
          SessionsCollection = @facade.retrieveProxy SESSIONS
          if @checkHeader()
            session = SessionsCollection.build {uid: 'system'}
          unless session?
            session = SessionsCollection.build()
          @session = session
          yield return

      @public @async systemOnly: Function,
        default: (args...)->
          yield @makeSession()
          unless @session?.uid?
            @context.throw UNAUTHORIZED
            return
          UsersCollection = @facade.retrieveProxy USERS
          currentUser = UsersCollection.build
            id: 'system'
            handle: 'system'
            email: 'system@leanrc.com'
            firstName: 'Owner'
            lastName: 'System'
            role: 'admin'
            accepted:                       yes
            verified:                       yes
            ownerId: 'system'
            inviterId: 'admin'
          @currentUser = currentUser
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
          yield return args


    ModelingResourceMixin.initializeMixin()
