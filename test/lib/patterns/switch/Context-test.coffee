{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
# accepts = require 'accepts'
httpErrors = require 'http-errors'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'Context', ->
  describe '.new', ->
    it 'should create Context instance', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.instanceOf context, Context
        assert.equal context.req, req
        assert.equal context.res, res
        assert.equal context.switch, switchInstance
        assert.instanceOf context.request, Test::Request
        assert.instanceOf context.response, Test::Response
        assert.instanceOf context.cookies, Test::Cookies
        assert.deepEqual context.state, {}
        yield return
  describe '#throw', ->
    it 'should throw an error exception', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.throws -> context.throw 404
        , httpErrors.HttpError
        assert.throws -> context.throw 501, 'Not Implemented'
        , httpErrors.HttpError
        yield return
  describe '#assert', ->
    it 'should assert with status codes', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Context extends LeanRC::Context
          @inheritProtected()
          @module Test
        Context.initialize()
        switchInstance =
          configs:
            trustProxy: yes
            cookieKey: 'COOKIE_KEY'
        req =
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        res =
          _headers: 'Foo': 'Bar'
        context = Context.new req, res, switchInstance
        assert.doesNotThrow -> context.assert yes
        assert.throws -> context.assert 'test' is 'TEST', 500, 'Internal Error'
        , Error
        yield return
