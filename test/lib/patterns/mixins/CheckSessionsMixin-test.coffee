{ IncomingMessage, ServerResponse } = require 'http'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
httpErrors = require 'http-errors'
LeanRC = require.main.require 'lib'
{
  FuncG, MaybeG
  CursorInterface
  Utils: { co }
} = LeanRC::

describe 'CheckSessionsMixin', ->
  describe '.new', ->
    it 'should create new resource', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::CheckSessionsMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
      .to.not.throw Error
  ### Moved to ModelingResourceMixin
  describe '#checkHeader', ->
    it 'should check if authorization header is present and correct', ->
      co ->
        KEY = 'TEST_CHECK_SESSIONS_MIXIN_001'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        facade = Test::Facade.getInstance KEY
        configs = Test::Configuration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends Test::Resource
          @inheritProtected()
          @include Test::CheckSessionsMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        class TestRouter extends Test::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Test::Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
          @initialize()
        body = '{"test":"test"}'
        class MyRequest extends IncomingMessage
          constructor: (socket) ->
            super socket
            @method = 'POST'
            @url = 'http://localhost:8888/space/SPACE123/test_entity'
            @headers =
              'x-forwarded-for': '192.168.0.1'
              'content-type': 'application/json'
              'content-length': "#{body.length}"
            @push body
            @push null
        class MyResponse extends ServerResponse
        req = new MyRequest
        res = new MyResponse req
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        resource = Test::TestResource.new()
        resource.context = Test::Context.new req, res, switchMediator
        resource.initializeNotifier KEY
        check = resource.checkHeader()
        assert.isFalse check
        req.headers.authorization = 'Bearer TESTTESTTESTTESTTEST'
        check = resource.checkHeader()
        assert.isFalse check
        req.headers.authorization = 'Bearer TESTTESTTESTTESTTEST123'
        check = resource.checkHeader()
        assert.isTrue check
        facade.remove()
        yield return
  ###
  describe '#makeSession', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should create session', ->
      co ->
        KEY = 'TEST_CHECK_SESSIONS_MIXIN_002'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        facade = Test::Facade.getInstance KEY
        configs = Test::Configuration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends Test::Resource
          @inheritProtected()
          @include Test::CheckSessionsMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        class TestRouter extends Test::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Test::Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
          @initialize()
        class SessionsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @include LeanRC::QueryableCollectionMixin
          @module Test
          ipoCollection = Symbol.for '~collection'
          @public @async takeBy: FuncG([Object, MaybeG Object], CursorInterface),
            default: (query, options = {})->
              id = query['@doc.id']
              yield return LeanRC::Cursor.new(@, [@[ipoCollection][id]])
          @initialize()
        class SessionRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          # @attribute id: String
          # @attribute rev: String
          # @attribute type: String
          @attribute uid: String
          # @attribute created: Number
          # @attribute expires: Number
          @attribute customData: Object
          # @chains ['create']
          # @beforeHook 'beforeCreate', only: [ 'create' ]
          @public @async beforeCreate: Function,
            default: (args...)->
              @id ?= LeanRC::Utils.genRandomAlphaNumbers 64
              # now = Date.now()
              now = new Date()
              @createdAt ?= now
              @updatedAt ?= now
              # @expires ?= now + 108000
              @uid ?= LeanRC::Utils.uuid.v4()
              yield return args
          @initialize()
        facade.registerProxy SessionsCollection.new Test::SESSIONS,
          delegate: 'SessionRecord'
        body = '{"test":"test"}'
        class MyRequest extends IncomingMessage
          constructor: (socket) ->
            super socket
            @method = 'POST'
            @url = 'http://localhost:8888/space/SPACE123/test_entity'
            @headers =
              'x-forwarded-for': '192.168.0.1'
              'content-type': 'application/json'
              'content-length': "#{body.length}"
              'authorization': 'Bearer TESTTESTTESTTESTTEST123'
            @push body
            @push null
        class MyResponse extends ServerResponse
        req = new MyRequest
        res = new MyResponse req
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        resource = Test::TestResource.new()
        resource.context = Test::Context.new req, res, switchMediator
        resource.initializeNotifier KEY
        yield resource.makeSession()
        assert.isUndefined resource.session.uid
        sessions = facade.retrieveProxy Test::SESSIONS
        session = yield sessions.create({})
        delete req.headers['authorization']
        req.headers.cookie = "#{configs.sessionCookie}=#{session.id}"
        yield resource.makeSession()
        assert.equal resource.session.uid, session.uid
        delete req.headers['cookie']
        yield resource.makeSession()
        assert.isFalse resource.session.uid?
        yield return
  describe '#checkSession', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should check if session valid', ->
      co ->
        KEY = 'TEST_CHECK_SESSIONS_MIXIN_003'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        facade = Test::Facade.getInstance KEY
        configs = Test::Configuration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends Test::Resource
          @inheritProtected()
          @include Test::CheckSessionsMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        class TestRouter extends Test::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Test::Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
          @initialize()
        # class MemoryCollection extends LeanRC::Collection
        #   @inheritProtected()
        #   @include LeanRC::MemoryCollectionMixin
        #   @include LeanRC::GenerateUuidIdMixin
        #   @include LeanRC::QueryableCollectionMixin
        #   @module Test
        #   ipoCollection = Symbol.for '~collection'
        #   @public @async takeBy: FuncG([Object, MaybeG Object], CursorInterface),
        #     default: (query, options = {})->
        #       id = query['@doc.id']
        #       yield return LeanRC::Cursor.new(@, [@[ipoCollection][id]])
        #   @initialize()
        class SessionsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @include LeanRC::QueryableCollectionMixin
          @module Test
          ipoCollection = Symbol.for '~collection'
          @public @async takeBy: FuncG([Object, MaybeG Object], CursorInterface),
            default: (query, options = {})->
              id = query['@doc.id']
              yield return LeanRC::Cursor.new(@, [@[ipoCollection][id]])
          @public userVerified: Boolean,
            default: no
          @public @async calcComputedsForOne: Function,
            default: (record) ->
              record.userIsAdmin = no
              record.userSpaceId = '234562362362452345'
              record.userVerified = @userVerified
              record.ownSpaces = []
              yield return record
          @initialize()
        class SessionRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          # @attribute id: String
          # @attribute rev: String
          # @attribute type: String
          @attribute uid: String
          # @attribute created: Number
          # @attribute expires: Number
          @attribute customData: Object
          # @chains ['create']
          # @beforeHook 'beforeCreate', only: [ 'create' ]
          @public @async beforeCreate: Function,
            default: (args...)->
              @id ?= LeanRC::Utils.genRandomAlphaNumbers 64
              # now = Date.now()
              now = new Date()
              @createdAt ?= now
              @updatedAt ?= now
              # @expires ?= now + 108000
              @uid ?= LeanRC::Utils.uuid.v4()
              yield return args
          @initialize()
        # class UserRecord extends Test::Record
        #   @inheritProtected()
        #   @module Test
        #   @attribute verified: Boolean, { default: no }
        # UserRecord.initialize()
        facade.registerProxy SessionsCollection.new Test::SESSIONS,
          delegate: 'SessionRecord'
        # facade.registerProxy MemoryCollection.new Test::USERS,
        #   delegate: UserRecord
        #   serializer: Test::Serializer
        body = '{"test":"test"}'
        class MyRequest extends IncomingMessage
          constructor: (socket) ->
            super socket
            @method = 'POST'
            @url = 'http://localhost:8888/space/SPACE123/test_entity'
            @headers =
              'x-forwarded-for': '192.168.0.1'
              'content-type': 'application/json'
              'content-length': "#{body.length}"
            @push body
            @push null
        class MyResponse extends ServerResponse
        req = new MyRequest
        res = new MyResponse req
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        try
          resource = TestResource.new()
          resource.context = Test::Context.new req, res, switchMediator
          resource.initializeNotifier KEY
          yield resource.checkSession()
        catch error1
        assert.instanceOf error1, httpErrors.Unauthorized
        # users = facade.retrieveProxy Test::USERS
        # user = yield users.create()
        sessions = facade.retrieveProxy Test::SESSIONS
        try
          session = yield sessions.create({})
          req.headers.cookie = "#{configs.sessionCookie}=#{session.id}"
          resource = Test::TestResource.new()
          resource.context = Test::Context.new req, res, switchMediator
          resource.initializeNotifier KEY
          yield resource.checkSession()
        catch error2
        assert.instanceOf error2, httpErrors.Unauthorized
        assert.propertyVal error2, 'message', 'Unverified'
        sessions.userVerified = yes
        session = yield sessions.create uid: 'ID123'
        req.headers.cookie = "#{configs.sessionCookie}=#{session.id}"
        resource = Test::TestResource.new()
        resource.context = Test::Context.new req, res, switchMediator
        resource.initializeNotifier KEY
        yield resource.checkSession()
        assert.equal resource.session.uid, 'ID123'
        yield return
