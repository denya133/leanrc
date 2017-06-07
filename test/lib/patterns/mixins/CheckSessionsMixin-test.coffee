{ IncomingMessage, ServerResponse } = require 'http'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'CheckSessionsMixin', ->
  describe '.new', ->
    it 'should create new resource', ->
      expect ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::CheckSessionsMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
      .to.not.throw Error
  describe '#checkHeader', ->
    it 'should check if authorization header is present and correct', ->
      co ->
        KEY = 'TEST_CHECK_SESSIONS_MIXIN_001'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        facade = Test::Facade.getInstance KEY
        configs = Test::Configuration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends Test::Resource
          @inheritProtected()
          @include Test::CheckSessionsMixin
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
  describe '#makeSession', ->
    it 'should create session', ->
      co ->
        KEY = 'TEST_CHECK_SESSIONS_MIXIN_002'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        facade = Test::Facade.getInstance KEY
        configs = Test::Configuration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends Test::Resource
          @inheritProtected()
          @include Test::CheckSessionsMixin
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
        class SessionCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        SessionCollection.initialize()
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
        facade.registerProxy SessionCollection.new Test::SESSIONS,
          delegate: Session
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
        assert.equal resource.session.uid, 'admin'
        sessions = facade.retrieveProxy Test::SESSIONS
        session = yield sessions.create()
        delete req.headers['authorization']
        req.headers.cookie = "#{configs.sessionCookie}=#{session.id}"
        yield resource.makeSession()
        assert.equal resource.session.uid, session.uid
        delete req.headers['cookie']
        yield resource.makeSession()
        assert.isFalse resource.session.uid?
        facade.remove()
        yield return
