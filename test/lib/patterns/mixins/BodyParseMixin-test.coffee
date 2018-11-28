{ IncomingMessage, ServerResponse } = require 'http'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'BodyParseMixin', ->
  describe '.new', ->
    it 'should create new resource', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::BodyParseMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
      .to.not.throw Error
  describe '#parseBody', ->
    it 'should parse request body', ->
      co ->
        KEY = 'TEST_BODY_PARSE_MIXIN_001'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        facade = Test::Facade.getInstance KEY
        configs = Test::Configuration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends Test::Resource
          @inheritProtected()
          @include Test::BodyParseMixin
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
        resource = TestResource.new()
        resource.context = Test::Context.new req, res, switchMediator
        yield resource.parseBody()
        assert.deepEqual resource.context.request.body, test: 'test'
        facade.remove()
        yield return
