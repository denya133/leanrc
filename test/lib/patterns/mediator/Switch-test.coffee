EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
Feed = require 'feed'
# httpErrors = require 'http-errors'
LeanRC = require.main.require 'lib'
RC = require 'RC'
Facade = LeanRC::Facade
Switch = LeanRC::Switch
{ co } = RC::Utils

describe 'Switch', ->
  describe '.new', ->
    it 'should create new switch mediator', ->
      expect ->
        mediatorName = 'TEST_MEDIATOR'
        switchMediator = Switch.new mediatorName
        assert.isArray switchMediator.middlewares
      .to.not.throw Error
  describe '#responseFormats', ->
    it 'should check allowed response formats', ->
      expect ->
        mediatorName = 'TEST_MEDIATOR'
        switchMediator = Switch.new mediatorName
        assert.deepEqual switchMediator.responseFormats, [
          'json', 'html', 'xml', 'atom'
        ], 'Property `responseFormats` returns incorrect values'
      .to.not.throw Error
  describe '#listNotificationInterests', ->
    it 'should check handled notifications list', ->
      expect ->
        mediatorName = 'TEST_MEDIATOR'
        switchMediator = Switch.new mediatorName
        assert.deepEqual switchMediator.listNotificationInterests(), [
          LeanRC::HANDLER_RESULT
        ], 'Function `listNotificationInterests` returns incorrect values'
      .to.not.throw Error
  describe '#handleNotification', ->
    it 'should try handle sent notification', ->
      co ->
        mediatorName = 'TEST_MEDIATOR'
        notitficationName = LeanRC::HANDLER_RESULT
        notificationBody = test: 'test'
        notitficationType = 'TEST_TYPE'
        notification = LeanRC::Notification.new notitficationName, notificationBody, notitficationType
        viewComponent = new EventEmitter
        switchMediator = Switch.new mediatorName, viewComponent
        promise = RC::Promise.new (resolve, reject) ->
          viewComponent.once notitficationType, (body) -> resolve body
          return
        switchMediator.handleNotification notification
        body = yield promise
        assert.deepEqual body, notificationBody
        yield return
  describe '#defineRoutes', ->
    it 'should define routes from route proxies', ->
      expect ->
        facade = Facade.getInstance 'TEST_SWITCH_1'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @map ->
            @resource 'test1', ->
              @resource 'test1'
            @namespace 'sub', ->
              @resource 'subtest'
        Test::TestRouter.initialize()
        facade.registerProxy Test::TestRouter.new 'TEST_SWITCH_ROUTER'
        spyCreateNativeRoute = sinon.spy ->
        class Test::TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
          @public createNativeRoute: Function,
            configurable: yes
            default: spyCreateNativeRoute
        Test::TestSwitch.initialize()
        switchMediator = Test::TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator.initializeNotifier 'TEST_SWITCH_1'
        switchMediator.defineRoutes()
        assert.equal spyCreateNativeRoute.callCount, 27, 'Some routes are missing'
        facade.remove()
      .to.not.throw Error
  describe '#onRegister', ->
    it 'should run register procedure', ->
      expect ->
        facade = Facade.getInstance 'TEST_SWITCH_2'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        Test::TestRouter.initialize()
        facade.registerProxy Test::TestRouter.new LeanRC::APPLICATION_ROUTER
        class Test::TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            default: LeanRC::APPLICATION_ROUTER
        Test::TestSwitch.initialize()
        switchMediator = Test::TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator.initializeNotifier 'TEST_SWITCH_2'
        switchMediator.onRegister()
        assert.instanceOf switchMediator.getViewComponent(), EventEmitter, 'Event emitter did not created'
        switchMediator.onRemove()
        facade.remove()
      .to.not.throw Error
  describe '#onRemove', ->
    it 'should run remove procedure', ->
      expect ->
        facade = Facade.getInstance 'TEST_SWITCH_3'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        Test::TestRouter.initialize()
        facade.registerProxy Test::TestRouter.new LeanRC::APPLICATION_ROUTER
        class Test::TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            default: LeanRC::APPLICATION_ROUTER
        Test::TestSwitch.initialize()
        switchMediator = Test::TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator.initializeNotifier 'TEST_SWITCH_3'
        switchMediator.onRegister()
        switchMediator.onRemove()
        assert.equal switchMediator.getViewComponent().eventNames().length, 0, 'Event listeners not cleared'
        facade.remove()
      .to.not.throw Error
  describe '#rendererFor', ->
    it 'should define renderers and get them one by one', ->
      expect ->
        facade = Facade.getInstance 'TEST_SWITCH_4'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        require.main.require('test/integration/renderers') Test
        facade.registerProxy Test::JsonRenderer.new 'TEST_JSON_RENDERER'
        facade.registerProxy Test::HtmlRenderer.new 'TEST_HTML_RENDERER'
        facade.registerProxy Test::XmlRenderer.new 'TEST_XML_RENDERER'
        facade.registerProxy Test::AtomRenderer.new 'TEST_ATOM_RENDERER'
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        Test::TestRouter.initialize()
        facade.registerProxy Test::TestRouter.new 'TEST_SWITCH_ROUTER'
        class Test::TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public jsonRendererName: String,
            default: 'TEST_JSON_RENDERER'
          @public htmlRendererName: String,
            default: 'TEST_HTML_RENDERER'
          @public xmlRendererName: String,
            default: 'TEST_XML_RENDERER'
          @public atomRendererName: String,
            default: 'TEST_ATOM_RENDERER'
          @public routerName: String,
            default: 'TEST_SWITCH_ROUTER'
        Test::TestSwitch.initialize()
        facade.registerMediator Test::TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        vhData =
          id: '123'
          title: 'Long story'
          author: name: 'John Doe', email: 'johndoe@example.com'
          description: 'True long story'
          updated: new Date()
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        jsonRendred = switchMediator.rendererFor('json').render vhData
        assert.equal jsonRendred, JSON.stringify(vhData), 'JSON did not rendered'
        htmlRendered = switchMediator.rendererFor('html').render vhData
        htmlRenderedGauge = '
        <html> <head> <title>Long story</title> </head> <body> <h1>Long story</h1> <p>True long story</p> </body> </html>
        '
        assert.equal htmlRendered, htmlRenderedGauge, 'HTML did not rendered'
        xmlRendered = switchMediator.rendererFor('xml').render vhData
        xmlRenderedGauge = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<root>
  <id>123</id>
  <title>Long story</title>
  <author>
    <name>John Doe</name>
    <email>johndoe@example.com</email>
  </author>
  <description>True long story</description>
  <updated/>
</root>'''
        assert.equal xmlRendered, xmlRenderedGauge, 'XML did not rendered'
        atomRendered = switchMediator.rendererFor('atom').render vhData
        atomRenderedGauge = (new Feed vhData).atom1()
        assert.equal atomRendered, atomRenderedGauge, 'ATOM did not rendered'
        facade.remove()
      .to.not.throw Error
  describe '#sendHttpResponse', ->
    it 'should send http response', ->
      co ->
        facade = Facade.getInstance 'TEST_SWITCH_5'
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        spyRendererRender = sinon.spy ->
        class TestRenderer extends LeanRC::Renderer
          @inheritProtected()
          @module Test
          @public render: Function,
            default: (aoData, aoOptions) ->
              spyRendererRender aoData, aoOptions
              vhData = RC::Utils.extend {}, aoData
              JSON.stringify vhData ? null
        TestRenderer.initialize()
        facade.registerProxy TestRenderer.new 'TEST_JSON_RENDERER'
        facade.registerProxy TestRenderer.new 'TEST_HTML_RENDERER'
        facade.registerProxy TestRenderer.new 'TEST_XML_RENDERER'
        facade.registerProxy TestRenderer.new 'TEST_ATOM_RENDERER'
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        spyResponseSet = sinon.spy ->
        class TestContext extends RC::CoreObject
          @inheritProtected()
          @module Test
          @public status: Number
          @public format: String
          @public accepts: Function,
            default: (alFormats = []) ->
              @format  if @format in alFormats
          @public set: Function,
            default: spyResponseSet
          @public body: LeanRC::ANY
          constructor: (args...) ->
            super args...
            [@format] = args
        TestContext.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public jsonRendererName: String,
            default: 'TEST_JSON_RENDERER'
          @public htmlRendererName: String,
            default: 'TEST_HTML_RENDERER'
          @public xmlRendererName: String,
            default: 'TEST_XML_RENDERER'
          @public atomRendererName: String,
            default: 'TEST_ATOM_RENDERER'
          @public routerName: String,
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        vhData =
          id: '123'
          title: 'Long story'
          author: name: 'John Doe', email: 'johndoe@example.com'
          description: 'True long story'
          updated: new Date()
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        renderedGauge = JSON.stringify vhData
        voContext = TestContext.new 'json'
        vhOptions =
          path: '/test'
          resource: 'test'
          action: 'list'
        yield switchMediator.sendHttpResponse voContext, vhData, vhOptions
        assert.isTrue spyRendererRender.calledWith(vhData, vhOptions), 'Render not called'
        assert.deepEqual voContext.body, renderedGauge
        facade.remove()
        yield return
  describe '#sender', ->
    it 'should send notification', ->
      expect ->
        facade = Facade.getInstance 'TEST_SWITCH_6'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        Test::TestRouter.initialize()
        facade.registerProxy Test::TestRouter.new 'TEST_SWITCH_ROUTER'
        # class AppConfiguration extends LeanRC::Configuration
        #   @inheritProtected()
        #   @module Test
        #   @public defineConfigProperties: Function,
        #     default: ->
        #   @public currentUserCookie: String,
        #     default: 'cuc'
        # AppConfiguration.initialize()
        # facade.registerProxy AppConfiguration.new LeanRC::CONFIGURATION
        class Test::TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            default: 'TEST_SWITCH_ROUTER'
        Test::TestSwitch.initialize()
        switchMediator = Test::TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator.initializeNotifier 'TEST_SWITCH_6'
        spySwitchSendNotification = sinon.spy switchMediator, 'sendNotification'
        vhParams =
          context: {}
          reverse: 'TEST_REVERSE'
        vhOptions =
          method: 'GET'
          path: '/test'
          resource: 'test'
          action: 'list'
        switchMediator.sender 'test', vhParams, vhOptions
        assert.isTrue spySwitchSendNotification.called, 'Notification not sent'
        assert.deepEqual spySwitchSendNotification.args[0], [
          'test'
          {
            context: {}
            reverse: 'TEST_REVERSE'
          }
          'list'
        ]
        facade.remove()
      .to.not.throw Error
  describe '#defineSwaggerEndpoint', ->
    it 'should define swagger endpoint', ->
      expect ->
        RESOURCE = 'test'
        facade = Facade.getInstance 'TEST_SWITCH_7'
        gateway = LeanRC::Gateway.new "#{RESOURCE}Gateway"
        listEndpoint = LeanRC::Endpoint.new { gateway }
        listEndpoint.tag 'TAG'
        listEndpoint.header 'header', {}, 'test header'
        listEndpoint.pathParam 'path-param', {}, 'test path param'
        listEndpoint.queryParam 'query-param', {}, 'test query param'
        listEndpoint.body {}, ['text/plain'], 'DESCRIPTION'
        listEndpoint.response 200, {}, ['text/plain'], 'DESCRIPTION'
        listEndpoint.error 500, {}, ['text/plain'], 'DESCRIPTION'
        listEndpoint.summary 'TEST_SUMMARY'
        listEndpoint.description 'DESCRIPTION'
        listEndpoint.deprecated yes
        gateway.setData endpoints:
          list: listEndpoint
        facade.registerProxy gateway
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        voEndpoint = LeanRC::Endpoint.new { gateway }
        switchMediator.defineSwaggerEndpoint voEndpoint, RESOURCE, 'list'
        assert.deepEqual listEndpoint, voEndpoint, 'Endpoints are not equivalent'
        facade.remove()
      .to.not.throw Error
  describe '.compose', ->
    it 'should dispatch middlewares', ->
      co ->
        facade = Facade.getInstance 'TEST_SWITCH_8'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        res =
          _headers: {}
        voContext = Test::Context.new req, res, switchMediator
        middlewares = []
        COUNT = 4
        for i in [ 0 .. COUNT ]
          middlewares.push sinon.spy (ctx, next) -> yield return next()
        fn = TestSwitch.compose middlewares
        yield fn voContext
        for i in [ 0 .. COUNT ]
          assert.isTrue middlewares[i].calledWith voContext
        facade.remove()
        yield return
  describe '.respond', ->
    it 'should run responding request handler', ->
      co ->
        trigger = new EventEmitter
        facade = Facade.getInstance 'TEST_SWITCH_9'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        req =
          method: 'POST'
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        res =
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data) -> trigger.emit 'end', data
        voContext = Test::Context.new req, res, switchMediator
        endPromise = LeanRC::Promise.new (resolve) -> trigger.once 'end', resolve
        voContext.status = 201
        switchMediator.respond voContext
        data = yield endPromise
        assert.equal data, 'Created'
        assert.equal voContext.status, 201
        assert.equal voContext.message, 'Created'
        assert.equal voContext.length, 7
        assert.equal voContext.type, 'text/plain'
        req =
          method: 'GET'
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        res =
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data) -> trigger.emit 'end', data
        voContext = Test::Context.new req, res, switchMediator
        endPromise = LeanRC::Promise.new (resolve) -> trigger.once 'end', resolve
        voContext.body = data: 'data'
        switchMediator.respond voContext
        data = yield endPromise
        assert.equal data, '{"data":"data"}'
        assert.equal voContext.status, 200
        assert.equal voContext.message, 'OK'
        assert.equal voContext.length, 15
        assert.equal voContext.type, 'application/json'
        facade.remove()
        yield return
  describe '#callback', ->
    it 'should run request handler', ->
      co ->
        facade = Facade.getInstance 'TEST_SWITCH_10'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
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
            @finished = no
            @_headers = {}
        req =
          url: 'http://localhost:8888'
          headers: 'x-forwarded-for': '192.168.0.1'
        res = new MyResponse
        switchMediator.middlewares = []
        switchMediator.middlewares.push (ctx, next) ->
          ctx.body = Buffer.from JSON.stringify data: 'data'
          yield return next()
        endPromise = LeanRC::Promise.new (resolve) -> res.once 'finish', resolve
        yield switchMediator.callback() req, res
        data = yield endPromise
        assert.equal data, '{"data":"data"}'
        res = new MyResponse
        switchMediator.middlewares.push (ctx, next) ->
          ctx.throw 404
          yield return next()
        endPromise = LeanRC::Promise.new (resolve) -> res.once 'finish', resolve
        yield switchMediator.callback() req, res
        data = yield endPromise
        assert.equal data, 'Not Found'
        res = new MyResponse
        switchMediator.middlewares = []
        switchMediator.middlewares.push (ctx, next) ->
          return ctx.res.emit 'error', new Error 'TEST'
          yield return next()
        endPromise = LeanRC::Promise.new (resolve) -> res.once 'finish', resolve
        yield switchMediator.callback() req, res
        data = yield endPromise
        facade.remove()
        yield return
  describe '#use', ->
    it 'should append middlewares', ->
      co ->
        trigger = new EventEmitter
        facade = Facade.getInstance 'TEST_SWITCH_11'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        class TestLogCommand extends LeanRC::SimpleCommand
          @inheritProtected()
          @module Test
          @public execute: Function,
            default: (aoNotification) -> trigger.emit 'log', aoNotification
        TestLogCommand.initialize()
        compareMiddlewares = (original, used) ->
          if used.__generatorFunction__?
            assert.equal used.__generatorFunction__, original
          else
            assert.equal used, original
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        facade.registerCommand Test::LogMessage.SEND_TO_LOG, TestLogCommand
        promise = LeanRC::Promise.new (resolve) -> trigger.once 'log', resolve
        testMiddlewareFirst = (ctx, next) -> yield return next?()
        middlewaresCount = switchMediator.middlewares.length
        switchMediator.use testMiddlewareFirst
        notification = yield promise
        assert.lengthOf switchMediator.middlewares, middlewaresCount + 1
        assert.equal notification.getBody(), 'use testMiddlewareFirst'
        usedMiddleware = switchMediator.middlewares[middlewaresCount]
        compareMiddlewares testMiddlewareFirst, usedMiddleware
        promise = LeanRC::Promise.new (resolve) -> trigger.once 'log', resolve
        testMiddlewareSecond = (ctx, next) -> return next?()
        middlewaresCount = switchMediator.middlewares.length
        switchMediator.use testMiddlewareSecond
        notification = yield promise
        assert.lengthOf switchMediator.middlewares, middlewaresCount + 1
        assert.equal notification.getBody(), 'use testMiddlewareSecond'
        usedMiddleware = switchMediator.middlewares[middlewaresCount]
        compareMiddlewares testMiddlewareSecond, usedMiddleware
        facade.remove()
        yield return
  describe '#onerror', ->
    it 'should handle error', ->
      co ->
        trigger = new EventEmitter
        facade = Facade.getInstance 'TEST_SWITCH_12'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        class TestLogCommand extends LeanRC::SimpleCommand
          @inheritProtected()
          @module Test
          @public execute: Function,
            default: (aoNotification) -> trigger.emit 'log', aoNotification
        TestLogCommand.initialize()
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        facade.registerCommand Test::LogMessage.SEND_TO_LOG, TestLogCommand
        promise = LeanRC::Promise.new (resolve) -> trigger.once 'log', resolve
        switchMediator.onerror new Error 'TEST_ERROR'
        message = yield promise
        assert.equal message.getName(), Test::LogMessage.SEND_TO_LOG
        assert.include message.getBody(), 'TEST_ERROR'
        assert.equal message.getType(), Test::LogMessage.LEVELS[Test::LogMessage.ERROR]
        facade.remove()
        yield return
  describe '#del', ->
    it 'should alias to #delete', ->
      co ->
        spyDelete = sinon.spy ->
        facade = Facade.getInstance 'TEST_SWITCH_13'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
          @public delete: Function, { default: spyDelete }
        TestSwitch.initialize()
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        switchMediator.del 'TEST'
        assert.isTrue spyDelete.calledWith 'TEST'
        yield return
  describe '#createMethod', ->
    it 'should create method handler', ->
      co ->
        trigger = new EventEmitter
        facade = Facade.getInstance 'TEST_SWITCH_13'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
          @createMethod 'get'
        TestSwitch.initialize()
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        assert.isFunction switchMediator.get.body
        lastMiddlewareIndex = switchMediator.middlewares.length
        spyMethod = sinon.spy ->
        switchMediator.get '/test/:id', (ctx, next) ->
          spyMethod JSON.stringify ctx.pathParams
          yield return next?()
        assert.isDefined switchMediator.middlewares[lastMiddlewareIndex]
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
            @finished = no
            @_headers = {}
        req =
          method: 'GET'
          url: 'http://localhost:8888/test2'
          headers: 'x-forwarded-for': '192.168.0.1'
        res = new MyResponse
        voContext = Test::Context.new req, res, switchMediator
        promise = LeanRC::Promise.new (resolve) -> res.once 'finish', resolve
        yield switchMediator.middlewares[lastMiddlewareIndex] voContext, -> res.end()
        yield promise
        assert.isFalse spyMethod.called
        spyMethod.reset()
        req =
          method: 'GET'
          url: 'http://localhost:8888/test/123'
          headers: 'x-forwarded-for': '192.168.0.1'
        res = new MyResponse
        voContext = Test::Context.new req, res, switchMediator
        promise = LeanRC::Promise.new (resolve) -> res.once 'finish', resolve
        yield switchMediator.middlewares[lastMiddlewareIndex] voContext, -> res.end()
        yield promise
        assert.isTrue spyMethod.calledWith '{"id":"123"}'
        facade.remove()
        yield return
