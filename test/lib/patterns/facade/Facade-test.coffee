{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{
  APPLICATION_MEDIATOR
  NilT
  FuncG
  FacadeInterface, NotificationInterface
  Facade
  SimpleCommand
  Notification
  Proxy
  Mediator
  Utils: { co }
} = LeanRC::

describe 'Facade', ->
  describe '.getInstance', ->
    it 'should get new or existing instance of Facade', ->
      expect ->
        facade = Facade.getInstance 'TEST1'
        assert facade instanceof Facade, 'The `facade` is not an instance of Facade'
        facade1 = Facade.getInstance 'TEST1'
        assert facade is facade1, 'Instances of facade not equal'
        facade.remove()
      .to.not.throw Error
  describe '#initializeNotifier', ->
    it 'should initialize notifier', ->
      facade = Facade.getInstance 'TEST2'
      ipsMultitonKey  = Symbol.for '~multitonKey'
      expect facade[ipsMultitonKey]
      .to.equal 'TEST2'
      facade.remove()
  describe '#registerCommand', ->
    it 'should register new command', ->
      expect ->
        facade = Facade.getInstance 'TEST3'
        class TestCommand extends SimpleCommand
          @inheritProtected()
        facade.registerCommand 'TEST_COMMAND', TestCommand
        assert facade.hasCommand 'TEST_COMMAND'
        facade.remove()
        return
      .to.not.throw Error
  describe '#lazyRegisterCommand', ->
    facade = null
    INSTANCE_NAME = 'TEST999'
    after ->
      facade?.remove()
    it 'should register new command lazily', ->
      co ->
        spy = sinon.spy()
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestCommand extends SimpleCommand
          @inheritProtected()
          @module Test
          @public execute: FuncG(NotificationInterface, NilT),
            default: spy
          @initialize()
        class Application extends Test::CoreObject
          @inheritProtected()
          @module Test
          @initialize()
        facade = Test::Facade.getInstance INSTANCE_NAME
        facade.registerMediator Test::Mediator.new APPLICATION_MEDIATOR, Application.new()
        vsNotificationName = 'TEST_COMMAND2'
        facade.lazyRegisterCommand vsNotificationName, 'TestCommand'
        assert facade.hasCommand vsNotificationName
        facade.sendNotification vsNotificationName
        assert spy.called
        yield return
  describe '#removeCommand', ->
    it 'should remove command if present', ->
      expect ->
        facade = Facade.getInstance 'TEST4'
        class TestCommand extends SimpleCommand
          @inheritProtected()
        facade.registerCommand 'TEST_COMMAND', TestCommand
        assert facade.hasCommand 'TEST_COMMAND'
        facade.removeCommand 'TEST_COMMAND'
        assert not facade.hasCommand 'TEST_COMMAND'
        facade.remove()
        return
      .to.not.throw Error
  describe '#hasCommand', ->
    it 'should register new command', ->
      expect ->
        facade = Facade.getInstance 'TEST5'
        class TestCommand extends SimpleCommand
          @inheritProtected()
        facade.registerCommand 'TEST_COMMAND', TestCommand
        assert facade.hasCommand 'TEST_COMMAND'
        assert not facade.hasCommand 'TEST_COMMAND_ABSENT'
        facade.remove()
        return
      .to.not.throw Error
  describe '#registerProxy', ->
    facade = null
    INSTANCE_NAME = 'TEST6'
    after ->
      facade?.remove()
    it 'should create new proxy and regiter it', ->
      co ->
        facade = Facade.getInstance INSTANCE_NAME
        onRegister = sinon.spy ->
        class TestProxy extends Proxy
          @inheritProtected()
          @public onRegister: Function,
            default: onRegister
        proxyData = { data: 'data' }
        testProxy = TestProxy.new 'TEST_PROXY', proxyData
        facade.registerProxy testProxy
        assert onRegister.called, 'Proxy is not registered'
        onRegister.reset()
        hasProxy = facade.hasProxy 'TEST_PROXY'
        assert hasProxy, 'Proxy is not registered'
        yield return
  describe '#lazyRegisterProxy', ->
    facade = null
    INSTANCE_NAME = 'TEST66'
    after ->
      facade?.remove()
    it 'should create new proxy and register it when needed', ->
      co ->
        onRegister = sinon.spy ->
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestProxy extends Proxy
          @inheritProtected()
          @module Test
          @public onRegister: Function,
            default: onRegister
          @initialize()
        class Application extends Test::CoreObject
          @inheritProtected()
          @module Test
          @initialize()
        facade = Facade.getInstance INSTANCE_NAME
        facade.registerMediator Test::Mediator.new Test::APPLICATION_MEDIATOR, Application.new()
        proxyData = { data: 'data' }
        facade.lazyRegisterProxy 'TEST_PROXY', 'TestProxy', proxyData
        assert.isFalse onRegister.called, 'Proxy is already registered'
        onRegister.reset()
        hasProxy = facade.hasProxy 'TEST_PROXY'
        assert hasProxy, 'Proxy is not registered'
        testProxy = facade.retrieveProxy 'TEST_PROXY'
        assert.instanceOf testProxy, TestProxy
        assert onRegister.called, 'Proxy is not registered'
        onRegister.reset()
        yield return
  describe '#retrieveProxy', ->
    it 'should retrieve registred proxy', ->
      expect ->
        facade = Facade.getInstance 'TEST7'
        class TestProxy extends Proxy
          @inheritProtected()
        proxyData = { data: 'data' }
        testProxy = TestProxy.new 'TEST_PROXY', proxyData
        facade.registerProxy testProxy
        retrievedProxy = facade.retrieveProxy 'TEST_PROXY'
        assert retrievedProxy is testProxy, 'Proxy cannot be retrieved'
        retrievedAbsentProxy = facade.retrieveProxy 'TEST_PROXY_ABSENT'
        hasNoAbsentProxy = not retrievedAbsentProxy?
        assert hasNoAbsentProxy, 'Absent proxy can be retrieved'
        facade.remove()
      .to.not.throw Error
  describe '#removeProxy', ->
    it 'should create new proxy and regiter it, after that remove it', ->
      expect ->
        facade = Facade.getInstance 'TEST8'
        onRemove = sinon.spy ->
        class TestProxy extends Proxy
          @inheritProtected()
          @public onRemove: Function,
            default: onRemove
        proxyData = { data: 'data' }
        testProxy = TestProxy.new 'TEST_PROXY2', proxyData
        facade.registerProxy testProxy
        hasProxy = facade.hasProxy 'TEST_PROXY2'
        assert hasProxy, 'Proxy is not registered'
        facade.removeProxy 'TEST_PROXY2'
        assert onRemove.called, 'Proxy is still registered'
        hasNoProxy = not facade.hasProxy 'TEST_PROXY2'
        assert hasNoProxy, 'Proxy is still registered'
        facade.remove()
      .to.not.throw Error
  describe '#hasProxy', ->
    it 'should retrieve registred proxy', ->
      expect ->
        facade = Facade.getInstance 'TEST9'
        class TestProxy extends Proxy
          @inheritProtected()
        proxyData = { data: 'data' }
        testProxy = TestProxy.new 'TEST_PROXY', proxyData
        facade.registerProxy testProxy
        hasProxy = facade.hasProxy 'TEST_PROXY'
        assert hasProxy, 'Proxy is absent'
        hasNoAbsentProxy = not facade.hasProxy 'TEST_PROXY_ABSENT'
        assert hasNoAbsentProxy, 'Absent proxy is accessible'
        facade.remove()
      .to.not.throw Error
  describe '#registerMediator', ->
    it 'should register new mediator', ->
      expect ->
        facade = Facade.getInstance 'TEST10'
        onRegister = sinon.spy ->
        handleNotification = sinon.spy ->
        viewComponent = {}
        class TestMediator extends Mediator
          @inheritProtected()
          @public listNotificationInterests: FuncG([], Array),
            default: -> [ 'TEST_LIST' ]
          @public handleNotification: FuncG(NotificationInterface),
            default: handleNotification
          @public onRegister: Function,
            default: onRegister
        mediator = TestMediator.new 'TEST_MEDIATOR', viewComponent
        facade.registerMediator mediator
        assert onRegister.called, 'Mediator is not registered'
        onRegister.reset()
        facade.notifyObservers Notification.new 'TEST_LIST'
        assert handleNotification.called, 'Mediator cannot subscribe interests'
        facade.remove()
      .to.not.throw Error
  describe '#retrieveMediator', ->
    it 'should retrieve registred mediator', ->
      expect ->
        facade = Facade.getInstance 'TEST11'
        viewComponent = {}
        class TestMediator extends Mediator
          @inheritProtected()
        mediator = TestMediator.new 'TEST_MEDIATOR', viewComponent
        facade.registerMediator mediator
        retrievedMediator = facade.retrieveMediator 'TEST_MEDIATOR'
        assert retrievedMediator is mediator, 'Cannot retrieve mediator'
        retrievedAbsentMediator = facade.retrieveMediator 'TEST_MEDIATOR_ABSENT'
        assert not retrievedAbsentMediator?, 'Retrieve absent mediator'
        facade.remove()
      .to.not.throw Error
  describe '#removeMediator', ->
    it 'should remove mediator', ->
      expect ->
        facade = Facade.getInstance 'TEST12'
        onRemove = sinon.spy ->
        viewComponent = {}
        class TestMediator extends Mediator
          @inheritProtected()
          @public onRemove: Function,
            default: onRemove
        mediator = TestMediator.new 'TEST_MEDIATOR', viewComponent
        facade.registerMediator mediator
        facade.removeMediator 'TEST_MEDIATOR'
        assert onRemove.called, 'Mediator onRemove hook not called'
        hasMediator = facade.hasMediator 'TEST_MEDIATOR'
        assert not hasMediator, 'Mediator didn\'t removed'
        facade.remove()
      .to.not.throw Error
  describe '#hasMediator', ->
    it 'should retrieve registred proxy', ->
      expect ->
        facade = Facade.getInstance 'TEST13'
        class TestMediator extends Mediator
          @inheritProtected()
        viewComponent = {}
        mediator = TestMediator.new 'TEST_MEDIATOR', viewComponent
        facade.registerMediator mediator
        hasMediator = facade.hasMediator 'TEST_MEDIATOR'
        assert hasMediator, 'Proxy is absent'
        hasNoAbsentsMediator = not facade.hasMediator 'TEST_MEDIATOR_ABSENT'
        assert hasNoAbsentsMediator, 'Absent proxy is accessible'
        facade.remove()
      .to.not.throw Error
  describe '#notifyObservers', ->
    it 'should call notification for all observers', ->
      expect ->
        facade = Facade.getInstance 'TEST14'
        handleNotification = sinon.spy ->
        viewComponent = {}
        class TestMediator extends Mediator
          @inheritProtected()
          @public listNotificationInterests: FuncG([], Array),
            default: -> [ 'TEST_LIST' ]
          @public handleNotification: FuncG(NotificationInterface),
            default: handleNotification
        mediator = TestMediator.new 'TEST_MEDIATOR', viewComponent
        facade.registerMediator mediator
        facade.notifyObservers Notification.new 'TEST_LIST'
        assert handleNotification.called, 'Mediator cannot subscribe interests'
        facade.remove()
      .to.not.throw Error
  describe '#sendNotification', ->
    it 'should send single notification', ->
      expect ->
        facade = Facade.getInstance 'TEST15'
        handleNotification = sinon.spy ->
        viewComponent = {}
        class TestMediator extends Mediator
          @inheritProtected()
          @public listNotificationInterests: FuncG([], Array),
            default: -> [ 'TEST_LIST' ]
          @public handleNotification: FuncG(NotificationInterface),
            default: handleNotification
        mediator = TestMediator.new 'TEST_MEDIATOR', viewComponent
        facade.registerMediator mediator
        facade.sendNotification 'TEST_LIST'
        assert handleNotification.called, 'Mediator cannot subscribe interests'
        facade.remove()
      .to.not.throw Error
  describe '#remove', ->
    it 'should remove facade', ->
      expect ->
        KEY = 'TEST16'
        facade = Facade.getInstance KEY
        instanceMapSymbol = Symbol.for '~instanceMap'
        assert.equal facade, Facade[instanceMapSymbol][KEY]
        facade.remove()
        assert.isUndefined Facade[instanceMapSymbol][KEY]
        facade.remove()
      .to.not.throw Error
  describe '.replicateObject', ->
    application = null
    KEY = 'TEST17'
    after -> application?.finish?()
    it 'should create replica for facade', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class ApplicationFacade extends LeanRC::Facade
          @inheritProtected()
          @module Test
          cphInstanceMap  = @classVariables['~instanceMap'].pointer
          @public startup: Function,
            default: (application) ->
              @registerCommand LeanRC::STARTUP, Test::PrepareViewCommand
              @sendNotification LeanRC::STARTUP, application
          @public finish: Function,
            default: ->
          @public @static getInstance: FuncG(String, FacadeInterface),
            default: (asKey)->
              vhInstanceMap = Test::Facade[cphInstanceMap]
              unless vhInstanceMap[asKey]?
                vhInstanceMap[asKey] = ApplicationFacade.new asKey
              vhInstanceMap[asKey]
        ApplicationFacade.initialize()
        class ApplicationMediator extends LeanRC::Mediator
          @inheritProtected()
          @module Test
        ApplicationMediator.initialize()
        class TestApplication extends LeanRC::Application
          @inheritProtected()
          @module Test
          @public @static NAME: String, { get: -> KEY }
        TestApplication.initialize()
        class PrepareViewCommand extends SimpleCommand
          @inheritProtected()
          @module Test
          @public execute: FuncG(NotificationInterface, NilT),
            default: (aoNotification)->
              voApplication = aoNotification.getBody()
              @facade.registerMediator ApplicationMediator.new LeanRC::APPLICATION_MEDIATOR, voApplication
        PrepareViewCommand.initialize()
        application = TestApplication.new()
        replica = yield ApplicationFacade.replicateObject application.facade
        assert.deepEqual replica,
          type: 'instance'
          class: 'ApplicationFacade'
          multitonKey: KEY
          application: 'TestApplication'
        yield return
  describe '.restoreObject', ->
    application = null
    KEY = 'TEST18'
    after -> application?.finish?()
    it 'should create replica for facade', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class ApplicationFacade extends LeanRC::Facade
          @inheritProtected()
          @module Test
          cphInstanceMap  = @classVariables['~instanceMap'].pointer
          @public startup: Function,
            default: (application) ->
              @registerCommand LeanRC::STARTUP, Test::PrepareViewCommand
              @sendNotification LeanRC::STARTUP, application
          @public finish: Function,
            default: ->
          @public @static getInstance: FuncG(String, FacadeInterface),
            default: (asKey)->
              vhInstanceMap = Test::Facade[cphInstanceMap]
              unless vhInstanceMap[asKey]?
                vhInstanceMap[asKey] = ApplicationFacade.new asKey
              vhInstanceMap[asKey]
        ApplicationFacade.initialize()
        class ApplicationMediator extends LeanRC::Mediator
          @inheritProtected()
          @module Test
        ApplicationMediator.initialize()
        class TestApplication extends LeanRC::Application
          @inheritProtected()
          @module Test
          @public @static NAME: String, { get: -> KEY }
        TestApplication.initialize()
        class PrepareViewCommand extends SimpleCommand
          @inheritProtected()
          @module Test
          @public execute: FuncG(NotificationInterface, NilT),
            default: (aoNotification)->
              voApplication = aoNotification.getBody()
              @facade.registerMediator ApplicationMediator.new LeanRC::APPLICATION_MEDIATOR, voApplication
        PrepareViewCommand.initialize()
        application = TestApplication.new()
        restoredFacade = yield ApplicationFacade.restoreObject Test,
          type: 'instance'
          class: 'ApplicationFacade'
          multitonKey: KEY
          application: 'TestApplication'
        assert.deepEqual application.facade, restoredFacade
        yield return
