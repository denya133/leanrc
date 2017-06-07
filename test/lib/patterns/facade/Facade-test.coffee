{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Facade = LeanRC::Facade
SimpleCommand = LeanRC::SimpleCommand
Notification = LeanRC::Notification
Proxy = LeanRC::Proxy
Mediator = LeanRC::Mediator

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
    it 'should create new proxy and regiter it', ->
      expect ->
        facade = Facade.getInstance 'TEST6'
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
        facade.remove()
      .to.not.throw Error
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
          @public listNotificationInterests: Function,
            default: -> [ 'TEST_LIST' ]
          @public handleNotification: Function,
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
          @public listNotificationInterests: Function,
            default: -> [ 'TEST_LIST' ]
          @public handleNotification: Function,
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
          @public listNotificationInterests: Function,
            default: -> [ 'TEST_LIST' ]
          @public handleNotification: Function,
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
