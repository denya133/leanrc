{ IncomingMessage, ServerResponse } = require 'http'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
httpErrors = require 'http-errors'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'CheckPermissionsMixin', ->
  describe '.new', ->
    it 'should create new resource', ->
      expect ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::CheckPermissionsMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        TestResource.initialize()
        resource = Test::TestResource.new()
      .to.not.throw Error
  describe '#_checkOwner', ->
    it 'should check if resource owner is matched', ->
      co ->
        KEY = 'TEST_CHECK_PERMISSIONS_MIXIN_001'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        facade = Test::Facade.getInstance KEY
        configs = Test::Configuration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends Test::Resource
          @inheritProtected()
          @include Test::CheckPermissionsMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        TestResource.initialize()
        class TestRouter extends Test::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Test::Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        MemoryCollection.initialize()
        class Space extends Test::Record
          @inheritProtected()
          @module Test
          @attribute ownerId: String
        Space.initialize()
        facade.registerProxy MemoryCollection.new Test::SPACES,
          delegate: Space
          serializer: Test::Serializer
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
        spaces = facade.retrieveProxy Test::SPACES
        space = yield spaces.create id: 'XXX', ownerId: 'YYY'
        resource = Test::TestResource.new()
        resource.context = Test::Context.new req, res, switchMediator
        resource.initializeNotifier KEY
        { pointer: key } = Test::TestResource.instanceMethods['_checkOwner']
        isOwner = yield resource[key] 'XXX', 'YYY'
        assert.isTrue isOwner
        isOwner = yield resource[key] 'XXX', 'YYY12'
        assert.isFalse isOwner
        facade.remove()
        yield return
  ###
  describe '#checkSession', ->
    it 'should check if session valid', ->
      co ->
        KEY = 'TEST_CHECK_SESSIONS_MIXIN_003'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        facade = Test::Facade.getInstance KEY
        configs = Test::Configuration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends Test::Resource
          @inheritProtected()
          @include Test::CheckPermissionsMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        TestResource.initialize()
        class TestRouter extends Test::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Test::Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        MemoryCollection.initialize()
        class Session extends Test::CoreObject
          @inheritProtected()
          @include Test::ChainsMixin
          @include Test::RecordMixin
          @module Test
          @attribute id: String
          @attribute rev: String
          @attribute type: String
          @attribute uid: String
          @attribute created: Number
          @attribute expires: Number
          @attribute data: Test::ANY
          @chains ['create']
          @beforeHook 'beforeCreate', only: [ 'create' ]
          @public @async beforeCreate: Function,
            default: ->
              @id ?= Test::Utils.genRandomAlphaNumbers 64
              now = Date.now()
              @created ?= now
              @expires ?= now + 108000
              @uid ?= Test::Utils.uuid.v4()
              yield return
        Session.initialize()
        class User extends Test::Record
          @inheritProtected()
          @module Test
          @attribute verified: Boolean, { default: no }
        User.initialize()
        facade.registerProxy MemoryCollection.new Test::SESSIONS,
          delegate: Session
          serializer: Test::Serializer
        facade.registerProxy MemoryCollection.new Test::USERS,
          delegate: User
          serializer: Test::Serializer
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
          resource = Test::TestResource.new()
          resource.context = Test::Context.new req, res, switchMediator
          resource.initializeNotifier KEY
          yield resource.checkSession()
        catch error1
        assert.instanceOf error1, httpErrors.Unauthorized
        users = facade.retrieveProxy Test::USERS
        user = yield users.create()
        sessions = facade.retrieveProxy Test::SESSIONS
        try
          session = yield sessions.create uid: user.id
          req.headers.cookie = "#{configs.sessionCookie}=#{session.id}"
          resource = Test::TestResource.new()
          resource.context = Test::Context.new req, res, switchMediator
          resource.initializeNotifier KEY
          yield resource.checkSession()
        catch error2
        assert.instanceOf error2, httpErrors.Unauthorized
        assert.propertyVal error2, 'message', 'Unverified'
        user.verified = yes
        yield user.save()
        req.headers.cookie = "#{configs.sessionCookie}=#{session.id}"
        resource = Test::TestResource.new()
        resource.context = Test::Context.new req, res, switchMediator
        resource.initializeNotifier KEY
        yield resource.checkSession()
        assert.equal resource.currentUser.id, user.id
        facade.remove()
        yield return
  ###
