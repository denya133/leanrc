EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
Feed = require 'feed'
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
      .to.not.throw Error
  describe '#onRegister', ->
    it 'should run register procedure', ->
      expect ->
        facade = Facade.getInstance 'TEST_SWITCH_2'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        Test::TestRouter.initialize()
        facade.registerProxy Test::TestRouter.new 'TEST_SWITCH_ROUTER'
        class Test::TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
          @public createNativeRoute: Function,
            configurable: yes
            default: ->
        Test::TestSwitch.initialize()
        switchMediator = Test::TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator.initializeNotifier 'TEST_SWITCH_1'
        switchMediator.onRegister()
        assert.instanceOf switchMediator.getViewComponent(), EventEmitter, 'Event emitter did not created'
      .to.not.throw Error
  describe '#onRemove', ->
    it 'should run remove procedure', ->
      expect ->
        facade = Facade.getInstance 'TEST_SWITCH_3'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        Test::TestRouter.initialize()
        facade.registerProxy Test::TestRouter.new 'TEST_SWITCH_ROUTER'
        class Test::TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
          @public createNativeRoute: Function,
            configurable: yes
            default: ->
        Test::TestSwitch.initialize()
        switchMediator = Test::TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator.initializeNotifier 'TEST_SWITCH_1'
        switchMediator.onRegister()
        switchMediator.onRemove()
        assert.equal switchMediator.getViewComponent().eventNames().length, 0, 'Event listeners not cleared'
      .to.not.throw Error
  describe '#rendererFor', ->
    it 'should define renderers and get them one by one', ->
      expect ->
        facade = Facade.getInstance 'TEST_SWITCH_4'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

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
          @public createNativeRoute: Function,
            default: ->
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
      .to.not.throw Error
  describe '#sendHttpResponse', ->
    it 'should send http response', ->
      expect ->
        facade = Facade.getInstance 'TEST_SWITCH_5'
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        spyRendererRender = sinon.spy ->
        class Test::TestRenderer extends LeanRC::Renderer
          @inheritProtected()
          @module Test
          @public render: Function,
            default: (aoData, aoOptions) ->
              spyRendererRender aoData, aoOptions
              vhData = RC::Utils.extend {}, aoData
              JSON.stringify vhData ? null
        Test::TestRenderer.initialize()
        facade.registerProxy Test::TestRenderer.new 'TEST_JSON_RENDERER'
        facade.registerProxy Test::TestRenderer.new 'TEST_HTML_RENDERER'
        facade.registerProxy Test::TestRenderer.new 'TEST_XML_RENDERER'
        facade.registerProxy Test::TestRenderer.new 'TEST_ATOM_RENDERER'
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        Test::TestRouter.initialize()
        class Test::Request extends RC::CoreObject
          @inheritProtected()
          @module Test
          @public format: String,
            default: 'json'
          @public accepts: Function,
            default: (alFormats = []) ->
              @format  if @format in alFormats
          constructor: (args...) ->
            super args...
            [@format] = args
        Test::Request.initialize()
        spyResponseSet = sinon.spy ->
        spyResponseSend = sinon.spy ->
        class Test::Response extends RC::CoreObject
          @inheritProtected()
          @module Test
          @public set: Function,
            default: spyResponseSet
          @public send: Function,
            default: spyResponseSend
        Test::Response.initialize()
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
          @public createNativeRoute: Function,
            default: ->
        Test::TestSwitch.initialize()
        facade.registerMediator Test::TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        vhData =
          id: '123'
          title: 'Long story'
          author: name: 'John Doe', email: 'johndoe@example.com'
          description: 'True long story'
          updated: new Date()
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        renderedGauge = JSON.stringify vhData
        voRequest = Test::Request.new 'json'
        voResponse = Test::Response.new()
        vhOptions =
          path: '/test'
          resource: 'test'
          action: 'list'
        switchMediator.sendHttpResponse voRequest, voResponse, vhData, vhOptions
        assert.isTrue spyRendererRender.calledWith(vhData, vhOptions), 'Render not called'
        assert.isTrue spyResponseSend.called, 'Response not sent'
        assert.isTrue spyResponseSend.calledWith(renderedGauge), 'Response data are incorrect'
      .to.not.throw Error
  describe '#handler', ->
    it 'should send notification', ->
      expect ->
        facade = Facade.getInstance 'TEST_SWITCH_6'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        Test::TestRouter.initialize()
        facade.registerProxy Test::TestRouter.new 'TEST_SWITCH_ROUTER'
        class AppConfiguration extends LeanRC::Configuration
          @inheritProtected()
          @module Test
          @public defineConfigProperties: Function,
            default: ->
          @public currentUserCookie: String,
            default: 'cuc'
        AppConfiguration.initialize()
        facade.registerProxy AppConfiguration.new LeanRC::CONFIGURATION
        class Test::TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
          @public createNativeRoute: Function,
            configurable: yes
            default: ->
        Test::TestSwitch.initialize()
        class Test::Request extends RC::CoreObject
          @inheritProtected()
          @module Test
          constructor: (args...) ->
            super args...
            @query = a: 1, b: 2, c: 'abc'
            @params = test: 'test'
            @cookies = cuc: 'CURRENT_USER_COOKIE'
            @headers = accept: 'json'
            @body = test: 'test'
        Test::Request.initialize()
        class Test::Response extends RC::CoreObject
          @inheritProtected()
          @module Test
        Test::Response.initialize()
        switchMediator = Test::TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator.initializeNotifier 'TEST_SWITCH_6'
        spySwitchSendNotification = sinon.spy switchMediator, 'sendNotification'
        vhParams =
          req: Test::Request.new()
          res: Test::Response.new()
          reverse: 'TEST_REVERSE'
        vhOptions =
          method: 'GET'
          path: '/test'
          resource: 'test'
          action: 'list'
        switchMediator.handler 'test', vhParams, vhOptions
        assert.isTrue spySwitchSendNotification.called, 'Notification not sent'
        assert.deepEqual spySwitchSendNotification.args[0], [
          'test'
          {
            queryParams: a: 1, b: 2, c: 'abc'
            pathPatams: test: 'test'
            currentUserId: 'CURRENT_USER_COOKIE'
            headers: accept: 'json'
            body: test: 'test'
            reverse: 'TEST_REVERSE'
          }
          'list'
        ]
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
        Test.initialize()

        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        Test::TestRouter.initialize()
        facade.registerProxy Test::TestRouter.new 'TEST_SWITCH_ROUTER'
        class Test::TestSwitch extends Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
          @public createNativeRoute: Function,
            configurable: yes
            default: ->
        facade.registerMediator Test::TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        voEndpoint = LeanRC::Endpoint.new { gateway }
        switchMediator.defineSwaggerEndpoint voEndpoint, RESOURCE, 'list'
        assert.deepEqual listEndpoint, voEndpoint, 'Endpoints are not equivalent'
      .to.not.throw Error
