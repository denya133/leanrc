{ Readable } = require 'stream'
EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
# accepts = require 'accepts'
httpErrors = require 'http-errors'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'Context', ->
  describe '.new', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should create Context instance', ->
      co ->
        KEY = 'TEST_CONTEXT_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.instanceOf context, TestContext
        assert.equal context.req, req
        assert.equal context.res, res
        assert.equal context.switch, switchMediator
        assert.instanceOf context.request, Test::Request
        assert.instanceOf context.response, Test::Response
        assert.instanceOf context.cookies, Test::Cookies
        assert.deepEqual context.state, {}
        yield return
  describe '#throw', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should throw an error exception', ->
      co ->
        KEY = 'TEST_CONTEXT_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.throws -> context.throw 404
        , httpErrors.HttpError
        assert.throws -> context.throw 501, 'Not Implemented'
        , httpErrors.HttpError
        yield return
  describe '#assert', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should assert with status codes', ->
      co ->
        KEY = 'TEST_CONTEXT_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.doesNotThrow -> context.assert yes
        assert.throws -> context.assert 'test' is 'TEST', 500, 'Internal Error'
        , Error
        yield return
  describe '#header', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request header', ->
      co ->
        KEY = 'TEST_CONTEXT_004'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.equal context.header, req.headers
        yield return
  describe '#headers', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request headers', ->
      co ->
        KEY = 'TEST_CONTEXT_005'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.equal context.headers, req.headers
        yield return
  describe '#method', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set request method', ->
      co ->
        KEY = 'TEST_CONTEXT_006'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.equal context.method, 'POST'
        context.method = 'PUT'
        assert.equal context.method, 'PUT'
        assert.equal req.method, 'PUT'
        yield return
  describe '#url', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set request URL', ->
      co ->
        KEY = 'TEST_CONTEXT_007'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.equal context.url, 'http://localhost:8888/test1'
        context.url = 'http://localhost:8888/test2'
        assert.equal context.url, 'http://localhost:8888/test2'
        assert.equal req.url, 'http://localhost:8888/test2'
        yield return
  describe '#originalUrl', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get original request URL', ->
      co ->
        KEY = 'TEST_CONTEXT_008'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.equal context.originalUrl, 'http://localhost:8888/test1'
        yield return
  describe '#origin', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request origin data', ->
      co ->
        KEY = 'TEST_CONTEXT_009'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:8888'
          secure: no
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'host': 'localhost:8888'
        #   secure: no
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.equal context.origin, 'http://localhost:8888'
        req.secure = yes
        assert.equal context.origin, 'https://localhost:8888'
        yield return
  describe '#href', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request hyper reference', ->
      co ->
        KEY = 'TEST_CONTEXT_010'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          method: 'POST'
          url: '/test1'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:8888'
          secure: no
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: '/test1'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'host': 'localhost:8888'
        #   secure: no
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.equal context.href, 'http://localhost:8888/test1'
        req.url = 'http://localhost1:9999/test2'
        context = TestContext.new req, res, switchMediator
        assert.equal context.href, 'http://localhost1:9999/test2'
        yield return
  describe '#path', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set request path', ->
      co ->
        KEY = 'TEST_CONTEXT_011'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1?t=ttt'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1?t=ttt'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.equal context.path, '/test1'
        context.path = '/test2'
        assert.equal context.path, '/test2'
        assert.equal req.url, 'http://localhost:8888/test2?t=ttt'
        yield return
  describe '#query', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set request query object', ->
      co ->
        KEY = 'TEST_CONTEXT_012'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1?t=ttt'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1?t=ttt'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.deepEqual context.query, t: 'ttt'
        context.query = a: 'aaa'
        assert.deepEqual context.query, a: 'aaa'
        assert.equal req.url, 'http://localhost:8888/test1?a=aaa'
        yield return
  describe '#querystring', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set request query string', ->
      co ->
        KEY = 'TEST_CONTEXT_013'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          method: 'POST'
          url: 'http://localhost:8888/test1?t=ttt'
          headers: 'x-forwarded-for': '192.168.0.1'
          secure: no
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'POST'
        #   url: 'http://localhost:8888/test1?t=ttt'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        #   secure: no
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.equal context.querystring, 't=ttt'
        context.querystring = 'a=aaa'
        assert.equal context.querystring, 'a=aaa'
        assert.equal req.url, 'http://localhost:8888/test1?a=aaa'
        yield return
  describe '#host', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request host', ->
      co ->
        KEY = 'TEST_CONTEXT_014'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:9999'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'host': 'localhost:9999'
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.equal context.host, 'localhost:9999'
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-host': 'localhost:8888, localhost:9999'
        context = TestContext.new req, res, switchMediator
        assert.equal context.host, 'localhost:8888'
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = TestContext.new req, res, switchMediator
        assert.equal context.host, ''
        yield return
  describe '#hostname', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request host name', ->
      co ->
        KEY = 'TEST_CONTEXT_015'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'Foo': 'Bar'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'localhost:9999'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'host': 'localhost:9999'
        # res =
        #   _headers: 'Foo': 'Bar'
        context = TestContext.new req, res, switchMediator
        assert.equal context.hostname, 'localhost'
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-host': 'localhost1:8888, localhost:9999'
        context = TestContext.new req, res, switchMediator
        assert.equal context.hostname, 'localhost1'
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        context = TestContext.new req, res, switchMediator
        assert.equal context.hostname, ''
        yield return
  describe '#fresh', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should test request freshness', ->
      co ->
        KEY = 'TEST_CONTEXT_016'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'etag': '"bar"'}
        res = new MyResponse
        req =
          method: 'GET'
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'GET'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'if-none-match': '"foo"'
        # res =
        #   _headers: 'etag': '"bar"'
        context = TestContext.new req, res, switchMediator
        context.status = 200
        assert.isFalse context.fresh
        req =
          method: 'GET'
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        res._headers = 'etag': '"foo"'
        context = TestContext.new req, res, switchMediator
        context.status = 200
        assert.isTrue context.fresh
        yield return
  describe '#stale', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should test request non-freshness', ->
      co ->
        KEY = 'TEST_CONTEXT_017'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'etag': '"bar"'}
        res = new MyResponse
        req =
          method: 'GET'
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   method: 'GET'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'if-none-match': '"foo"'
        # res =
        #   _headers: 'etag': '"bar"'
        context = TestContext.new req, res, switchMediator
        context.status = 200
        assert.isTrue context.stale
        req =
          method: 'GET'
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'if-none-match': '"foo"'
        res._headers = 'etag': '"foo"'
        context = TestContext.new req, res, switchMediator
        context.status = 200
        assert.isFalse context.stale
        yield return
  describe '#socket', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request socket', ->
      co ->
        KEY = 'TEST_CONTEXT_018'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
          socket: {}
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #   socket: {}
        # res = _headers: {}
        context = TestContext.new req, res, switchMediator
        assert.equal context.socket, req.socket
        yield return
  describe '#protocol', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request protocol', ->
      co ->
        KEY = 'TEST_CONTEXT_019'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: no
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res = _headers: {}
        Reflect.defineProperty switchMediator, 'configs',
          writable: yes
          value: trustProxy: no
        context = TestContext.new req, res, switchMediator
        assert.equal context.protocol, 'http'
        Reflect.defineProperty switchMediator, 'configs',
          writable: yes
          value: trustProxy: yes
        context = TestContext.new req, res, switchMediator
        assert.equal context.protocol, 'http'
        req.socket = encrypted: yes
        context = TestContext.new req, res, switchMediator
        assert.equal context.protocol, 'https'
        delete req.socket
        req.secure = yes
        context = TestContext.new req, res, switchMediator
        assert.equal context.protocol, 'https'
        delete req.secure
        req.headers['x-forwarded-proto'] = 'https'
        context = TestContext.new req, res, switchMediator
        assert.equal context.protocol, 'https'
        yield return
  describe '#secure', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should check if request secure', ->
      co ->
        KEY = 'TEST_CONTEXT_020'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: no
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res = _headers: {}
        Reflect.defineProperty switchMediator, 'configs',
          writable: yes
          value: trustProxy: no
        context = TestContext.new req, res, switchMediator
        assert.isFalse context.secure
        Reflect.defineProperty switchMediator, 'configs',
          writable: yes
          value: trustProxy: yes
        # switchInstance.configs.trustProxy = yes
        context = TestContext.new req, res, switchMediator
        assert.isFalse context.secure
        req.socket = encrypted: yes
        context = TestContext.new req, res, switchMediator
        assert.isTrue context.secure
        delete req.socket
        req.secure = yes
        context = TestContext.new req, res, switchMediator
        assert.isTrue context.secure
        delete req.secure
        req.headers['x-forwarded-proto'] = 'https'
        context = TestContext.new req, res, switchMediator
        assert.isTrue context.secure
        yield return
  describe '#ips', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request IPs', ->
      co ->
        KEY = 'TEST_CONTEXT_021'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1, 192.168.1.1, 123.222.12.21'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1, 192.168.1.1, 123.222.12.21'
        # res = _headers: {}
        context = TestContext.new req, res, switchMediator
        assert.deepEqual context.ips, [ '192.168.0.1', '192.168.1.1', '123.222.12.21' ]
        yield return
  describe '#ip', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request IP', ->
      co ->
        KEY = 'TEST_CONTEXT_022'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1, 192.168.1.1, 123.222.12.21'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1, 192.168.1.1, 123.222.12.21'
        # res = _headers: {}
        context = TestContext.new req, res, switchMediator
        assert.deepEqual context.ip, '192.168.0.1'
        yield return
  describe '#subdomains', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get request subdomains', ->
      co ->
        KEY = 'TEST_CONTEXT_023'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'host': 'www.test.localhost:9999'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        #     subdomainOffset: 1
        # req =
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'host': 'www.test.localhost:9999'
        # res = _headers: {}
        context = TestContext.new req, res, switchMediator
        assert.deepEqual context.subdomains, [ 'test', 'www' ]
        req.headers.host = '192.168.0.2:9999'
        context = TestContext.new req, res, switchMediator
        assert.deepEqual context.subdomains, []
        yield return
  describe '#is', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should test types from request', ->
      co ->
        KEY = 'TEST_CONTEXT_024'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {'etag': '"bar"'}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'content-type': 'application/json'
            'content-length': '0'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'content-type': 'application/json'
        #     'content-length': '0'
        # res =
        #   _headers: 'etag': '"bar"'
        context = TestContext.new req, res, switchMediator
        assert.equal context.is('html' , 'application/*'), 'application/json'
        yield return
  describe '#accepts', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get acceptable types from request', ->
      co ->
        KEY = 'TEST_CONTEXT_025'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept': 'application/json, text/plain, image/png'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept': 'application/json, text/plain, image/png'
        # res = _headers: {}
        context = TestContext.new req, res, switchMediator
        assert.deepEqual context.accepts(), [
          'application/json', 'text/plain', 'image/png'
        ]
        yield return
  describe '#acceptsEncodings', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get acceptable encodings from request', ->
      co ->
        KEY = 'TEST_CONTEXT_026'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept-encoding': 'compress, gzip, deflate, sdch, identity'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept-encoding': 'compress, gzip, deflate, sdch, identity'
        # res = _headers: {}
        context = TestContext.new req, res, switchMediator
        assert.deepEqual context.acceptsEncodings(), [
          'compress', 'gzip', 'deflate', 'sdch', 'identity'
        ]
        yield return
  describe '#acceptsCharsets', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get acceptable charsets from request', ->
      co ->
        KEY = 'TEST_CONTEXT_027'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept-charset': 'utf-8, iso-8859-1;q=0.5, *;q=0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept-charset': 'utf-8, iso-8859-1;q=0.5, *;q=0.1'
        # res = _headers: {}
        context = TestContext.new req, res, switchMediator
        assert.deepEqual context.acceptsCharsets(), [
          'utf-8', 'iso-8859-1', '*'
        ]
        yield return
  describe '#acceptsLanguages', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get acceptable languages from request', ->
      co ->
        KEY = 'TEST_CONTEXT_028'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept-language': 'en, ru, cn, fr'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept-language': 'en, ru, cn, fr'
        # res = _headers: {}
        context = TestContext.new req, res, switchMediator
        assert.deepEqual context.acceptsLanguages(), [
          'en', 'ru', 'cn', 'fr'
        ]
        yield return
  describe '#get', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get single header from request', ->
      co ->
        KEY = 'TEST_CONTEXT_029'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'referrer': 'localhost'
            'x-forwarded-for': '192.168.0.1'
            'x-forwarded-proto': 'https'
            'abc': 'def'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers:
        #     'referrer': 'localhost'
        #     'x-forwarded-for': '192.168.0.1'
        #     'x-forwarded-proto': 'https'
        #     'abc': 'def'
        # res = _headers: {}
        context = TestContext.new req, res, switchMediator
        assert.equal context.get('Referrer'), 'localhost'
        assert.equal context.get('X-Forwarded-For'), '192.168.0.1'
        assert.equal context.get('X-Forwarded-Proto'), 'https'
        assert.equal context.get('Abc'), 'def'
        assert.equal context.get('123'), ''
        yield return
  describe '#body', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set response body', ->
      co ->
        KEY = 'TEST_CONTEXT_030'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        assert.isUndefined context.body
        context.body = 'TEST'
        assert.equal context.status, 200
        assert.equal context.message, 'OK'
        assert.equal context.response.get('Content-Type'), 'text/plain; charset=utf-8'
        assert.equal context.response.get('Content-Length'), '4'
        context.body = null
        assert.equal context.status, 204
        assert.equal context.message, 'No Content'
        assert.equal context.response.get('Content-Type'), ''
        assert.equal context.response.get('Content-Length'), ''
        context.response._explicitStatus = no
        context.body = Buffer.from '7468697320697320612074c3a97374', 'hex'
        assert.equal context.status, 200
        assert.equal context.message, 'OK'
        assert.equal context.response.get('Content-Type'), 'application/octet-stream'
        assert.equal context.response.get('Content-Length'), '15'
        context.body = null
        context.response._explicitStatus = no
        context.body = '<html></html>'
        assert.equal context.status, 200
        assert.equal context.message, 'OK'
        assert.equal context.response.get('Content-Type'), 'text/html; charset=utf-8'
        assert.equal context.response.get('Content-Length'), '13'
        data = 'asdfsdzdfvhasdvsjvcsdvcivsiubcuibdsubs\nbszdbiszdbvibdivbsdibvsd'
        class MyStream extends Readable
          constructor: (options = {}) ->
            super options
            @__data = options.data
            return
          _read:(size) ->
            @push @__data[0 ... size]
            @push null
            return
        stream = new MyStream { data }
        context.body = null
        context.response._explicitStatus = no
        context.body = stream
        stream.read()
        assert.equal context.status, 200
        assert.equal context.message, 'OK'
        assert.equal context.response.get('Content-Type'), 'application/octet-stream'
        assert.equal context.response.get('Content-Length'), ''
        context.body = null
        context.response._explicitStatus = no
        context.body = { test: 'TEST' }
        assert.equal context.status, 200
        assert.equal context.message, 'OK'
        assert.equal context.response.get('Content-Type'), 'application/json; charset=utf-8'
        assert.equal context.response.get('Content-Length'), ''
        yield return
  describe '#status', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set response status', ->
      co ->
        KEY = 'TEST_CONTEXT_031'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          statusCode: 200
          statusMessage: 'OK'
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   statusCode: 200
        #   statusMessage: 'OK'
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        assert.equal context.status, 200
        context.status = 400
        assert.equal context.status, 400
        assert.equal res.statusCode, 400
        assert.throws -> context.status = 'TEST'
        assert.throws -> context.status = 0
        assert.doesNotThrow -> context.status = 200
        res.headersSent = yes
        assert.throws -> context.status = 200
        yield return
  describe '#message', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set response message', ->
      co ->
        KEY = 'TEST_CONTEXT_032'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          statusCode: 200
          statusMessage: 'OK'
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   statusCode: 200
        #   statusMessage: 'OK'
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        assert.equal context.message, 'OK'
        context.message = 'TEST'
        assert.equal context.message, 'TEST'
        assert.equal res.statusMessage, 'TEST'
        yield return
  describe '#length', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get and set response body length', ->
      co ->
        KEY = 'TEST_CONTEXT_033'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        assert.equal context.length, 0
        context.length = 10
        assert.equal context.length, 10
        context.response.remove 'Content-Length'
        context.body = '<html></html>'
        assert.equal context.length, 13
        context.response.remove 'Content-Length'
        context.body = Buffer.from '7468697320697320612074c3a97374', 'hex'
        assert.equal context.length, 15
        context.response.remove 'Content-Length'
        context.body = test: 'TEST123'
        assert.equal context.length, 18
        yield return
  describe '#writable', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should check if response is writable', ->
      co ->
        KEY = 'TEST_CONTEXT_034'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: yes, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   _headers: {}
        #   finished: yes
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        assert.isFalse context.writable
        res.finished = no
        context = TestContext.new req, res, switchMediator
        assert.isTrue context.writable
        delete res.finished
        context = TestContext.new req, res, switchMediator
        assert.isTrue context.writable
        res.socket = writable: yes
        assert.isTrue context.writable
        res.socket.writable = no
        context = TestContext.new req, res, switchMediator
        assert.isFalse context.writable
        yield return
  describe '#type', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get, set and remove `Content-Type` header', ->
      co ->
        KEY = 'TEST_CONTEXT_035'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        assert.equal context.type, ''
        context.type = 'markdown'
        assert.equal context.type, 'text/markdown'
        assert.equal res._headers['content-type'], 'text/markdown; charset=utf-8'
        context.type = 'file.json'
        assert.equal context.type, 'application/json'
        assert.equal res._headers['content-type'], 'application/json; charset=utf-8'
        context.type = 'text/html'
        assert.equal context.type, 'text/html'
        assert.equal res._headers['content-type'], 'text/html; charset=utf-8'
        context.type = null
        assert.equal context.type, ''
        assert.isUndefined res._headers['content-type']
        yield return
  describe '#headerSent', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get res.headersSent value', ->
      co ->
        KEY = 'TEST_CONTEXT_036'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          headersSent: yes
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   headersSent: yes
        #   _headers: {}
        context = TestContext.new req, res, switchMediator
        assert.equal context.headerSent, res.headersSent
        yield return
  describe '#redirect', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should send redirect', ->
      co ->
        KEY = 'TEST_CONTEXT_037'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers:
            'x-forwarded-for': '192.168.0.1'
            'accept': 'application/json, text/plain, image/png'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers:
        #     'x-forwarded-for': '192.168.0.1'
        #     'accept': 'application/json, text/plain, image/png'
        # res =
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        context.redirect 'back', 'http://localhost:8888/test1'
        assert.equal context.response.get('Location'), 'http://localhost:8888/test1'
        assert.equal context.status, 302
        assert.equal context.message, 'Found'
        assert.equal context.type, 'text/plain'
        assert.equal context.body, 'Redirecting to http://localhost:8888/test1'
        req.headers.referrer = 'http://localhost:8888/test3'
        context.redirect 'back'
        assert.equal context.response.get('Location'), 'http://localhost:8888/test3'
        assert.equal context.status, 302
        assert.equal context.message, 'Found'
        assert.equal context.type, 'text/plain'
        assert.equal context.body, 'Redirecting to http://localhost:8888/test3'
        context.redirect 'http://localhost:8888/test2'
        assert.equal context.response.get('Location'), 'http://localhost:8888/test2'
        assert.equal context.status, 302
        assert.equal context.message, 'Found'
        assert.equal context.type, 'text/plain'
        assert.equal context.body, 'Redirecting to http://localhost:8888/test2'
        yield return
  describe '#attachment', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should setup attachment', ->
      co ->
        KEY = 'TEST_CONTEXT_038'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        context.attachment "#{__dirname}/#{__filename}"
        assert.equal context.type, 'text/coffeescript'
        assert.equal context.response.get('Content-Disposition'), 'attachment; filename="Context-test.coffee"'
        context.attachment 'attachment.js'
        assert.equal context.type, 'application/javascript'
        assert.equal context.response.get('Content-Disposition'), 'attachment; filename="attachment.js"'
        yield return
  describe '#set', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should set specified response header', ->
      co ->
        KEY = 'TEST_CONTEXT_039'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        context.set 'Content-Type', 'text/plain'
        assert.equal res._headers['content-type'], 'text/plain'
        assert.equal context.response.get('Content-Type'), 'text/plain'
        now = new Date
        context.set 'Date', now
        assert.equal context.response.get('Date'), "#{now}"
        array = [ 1, now, 'TEST']
        context.set 'Test', array
        assert.deepEqual context.response.get('Test'), [ '1', "#{now}", 'TEST']
        context.set
          'Abc': 123
          'Last-Date': now
          'New-Test': 'Test'
        assert.equal context.response.get('Abc'), '123'
        assert.equal context.response.get('Last-Date'), "#{now}"
        assert.equal context.response.get('New-Test'), 'Test'
        yield return
  describe '#append', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should add specified response header value', ->
      co ->
        KEY = 'TEST_CONTEXT_040'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        context.append 'Test', 'data'
        assert.equal context.response.get('Test'), 'data'
        context.append 'Test', 'Test'
        assert.deepEqual context.response.get('Test'), [ 'data', 'Test' ]
        context.append 'Test', 'Test'
        assert.deepEqual context.response.get('Test'), [ 'data', 'Test', 'Test' ]
        yield return
  describe '#vary', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should set `Vary` header', ->
      co ->
        KEY = 'TEST_CONTEXT_041'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   getHeader: (field) -> @_headers[field.toLowerCase()]
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        context.vary 'Origin'
        assert.equal context.response.get('Vary'), 'Origin'
        yield return
  describe '#flushHeaders', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should clear all headers', ->
      co ->
        KEY = 'TEST_CONTEXT_042'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   getHeader: (field) -> @_headers[field.toLowerCase()]
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        now = new Date
        array = [ 1, now, 'TEST']
        context.set
          'Content-Type': 'text/plain'
          'Date': now
          'Abc': 123
          'Last-Date': now
          'New-Test': 'Test'
          'Test': array
        assert.equal context.response.get('Content-Type'), 'text/plain'
        assert.equal context.response.get('Date'), "#{now}"
        assert.equal context.response.get('Abc'), '123'
        assert.equal context.response.get('Last-Date'), "#{now}"
        assert.equal context.response.get('New-Test'), 'Test'
        assert.deepEqual context.response.get('Test'), [ '1', "#{now}", 'TEST']
        context.flushHeaders()
        assert.equal context.response.get('Content-Type'), ''
        assert.equal context.response.get('Date'), ''
        assert.equal context.response.get('Abc'), ''
        assert.equal context.response.get('Last-Date'), ''
        assert.equal context.response.get('New-Test'), ''
        assert.equal context.response.get('Test'), ''
        yield return
  describe '#remove', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should remove specified response header', ->
      co ->
        KEY = 'TEST_CONTEXT_043'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   getHeader: (field) -> @_headers[field.toLowerCase()]
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        context.set 'Test', 'data'
        assert.equal context.response.get('Test'), 'data'
        context.remove 'Test'
        assert.equal context.response.get('Test'), ''
        yield return
  describe '#lastModified', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should set `Last-Modified` header', ->
      co ->
        KEY = 'TEST_CONTEXT_044'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   getHeader: (field) -> @_headers[field.toLowerCase()]
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        now = new Date
        context.lastModified = now
        assert.equal res._headers['last-modified'], now.toUTCString()
        assert.deepEqual context.response.lastModified, new Date now.toUTCString()
        yield return
  describe '#etag', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should set `ETag` header', ->
      co ->
        KEY = 'TEST_CONTEXT_045'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        # switchInstance =
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   getHeader: (field) -> @_headers[field.toLowerCase()]
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        context = TestContext.new req, res, switchMediator
        etag = '123456789'
        context.etag = etag
        assert.equal res._headers['etag'], "\"#{etag}\""
        assert.deepEqual context.response.etag, "\"#{etag}\""
        etag = 'W/"123456789"'
        context.etag = etag
        assert.equal res._headers['etag'], etag
        assert.deepEqual context.response.etag, etag
        yield return
  describe '#onerror', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should run error handler', ->
      co ->
        KEY = 'TEST_CONTEXT_046'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/../command/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestContext extends LeanRC::Context
          @inheritProtected()
          @module Test
          @initialize()
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            trigger.emit 'end', data
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        res = new MyResponse
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        Reflect.defineProperty switchMediator, 'getViewComponent',
          value: -> trigger
        # switchInstance =
        #   getViewComponent: -> trigger
        #   configs:
        #     trustProxy: yes
        #     cookieKey: 'COOKIE_KEY'
        # req =
        #   url: 'http://localhost:8888'
        #   headers: 'x-forwarded-for': '192.168.0.1'
        # res =
        #   _headers: {}
        #   getHeaders: -> LeanRC::Utils.copy @_headers
        #   getHeader: (field) -> @_headers[field.toLowerCase()]
        #   setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
        #   removeHeader: (field) -> delete @_headers[field.toLowerCase()]
        #   end: (data) -> trigger.emit 'end', data
        context = TestContext.new req, res, switchMediator
        errorPromise = LeanRC::Promise.new (resolve) ->
          trigger.once 'error', resolve
        endPromise = LeanRC::Promise.new (resolve) ->
          trigger.once 'end', resolve
        context.onerror 'TEST_ERROR'
        err = yield errorPromise
        data = yield endPromise
        assert.instanceOf err, Error
        assert.equal err.message, 'non-error thrown: TEST_ERROR'
        assert.equal err.status, 500
        assert.include data, '"Internal Server Error"'
        context = TestContext.new req, res, switchMediator
        errorPromise = LeanRC::Promise.new (resolve) ->
          trigger.once 'error', resolve
        endPromise = LeanRC::Promise.new (resolve) ->
          trigger.once 'end', resolve
        context.onerror new Error 'TEST_ERROR'
        err = yield errorPromise
        data = yield endPromise
        assert.instanceOf err, Error
        assert.equal err.message, 'TEST_ERROR'
        assert.equal err.status, 500
        assert.include data, '"Internal Server Error"'
        context = TestContext.new req, res, switchMediator
        errorPromise = LeanRC::Promise.new (resolve) ->
          trigger.once 'error', resolve
        endPromise = LeanRC::Promise.new (resolve) ->
          trigger.once 'end', resolve
        context.onerror httpErrors 400, 'TEST_ERROR'
        err = yield errorPromise
        data = yield endPromise
        assert.instanceOf err, httpErrors.BadRequest
        assert.isTrue err.expose
        assert.equal err.message, 'TEST_ERROR'
        assert.equal err.status, 400
        assert.include data, '"TEST_ERROR"'
        yield return
