EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
RC = require 'RC'
Facade = LeanRC::Facade
Switch = LeanRC::Switch

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
          LeanRC::Constants.HANDLER_RESULT
        ], 'Function `listNotificationInterests` returns incorrect values'
      .to.not.throw Error
  describe '#defineRoutes', ->
    it 'should define routes from route proxies', ->
      expect ->
        facade = Facade.getInstance 'TEST_SWITCH_1'
        class Test extends RC::Module
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @Module: Test
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
          @Module: Test
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
        assert.equal spyCreateNativeRoute.callCount, 18, 'Some routes are missing'
      .to.not.throw Error
  describe '#onRegister', ->
    it 'should run register procedure', ->
      expect ->
        facade = Facade.getInstance 'TEST_SWITCH_1'
        class Test extends RC::Module
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @Module: Test
        Test::TestRouter.initialize()
        facade.registerProxy Test::TestRouter.new 'TEST_SWITCH_ROUTER'
        class Test::TestSwitch extends Switch
          @inheritProtected()
          @Module: Test
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
  describe 'register mediator', ->
    it 'should register switch into view', ->
      # expect ->
      #   facade = Facade.getInstance 'TEST_SWITCH_XXX'
      #   switchMediator = Switch.new 'TEST_SWITCH_MEDIATOR'
      #   facade.registerMediator switchMediator
      # .to.not.throw Error
