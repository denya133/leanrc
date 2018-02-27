{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{
  APPLICATION_MEDIATOR

  Model
  Proxy
  Utils: { co }
} = LeanRC::

describe 'Model', ->
  describe '.getInstance', ->
    it 'should get new or existing instance of Model', ->
      expect ->
        model = Model.getInstance 'TEST1'
        assert model instanceof Model, 'The `model` is not an instance of Model'
      .to.not.throw Error
  describe '.removeModel', ->
    it 'should get new instance of Model, remove it and get new one', ->
      expect ->
        model = Model.getInstance 'TEST2'
        oldModel = Model.getInstance 'TEST2'
        assert model is oldModel, 'Model is not saved'
        Model.removeModel 'TEST2'
        newModel = Model.getInstance 'TEST2'
        assert model isnt newModel, 'Model instance didn\'t renewed'
      .to.not.throw Error
  describe '#registerProxy', ->
    it 'should create new proxy and register it', ->
      expect ->
        model = Model.getInstance 'TEST3'
        onRegister = sinon.spy()
        class TestProxy extends Proxy
          @inheritProtected()
          @public onRegister: Function,
            default: onRegister
        proxyData = { data: 'data' }
        testProxy = TestProxy.new 'TEST_PROXY', proxyData
        model.registerProxy testProxy
        assert onRegister.called, 'Proxy is not registered'
        onRegister.reset()
        hasProxy = model.hasProxy 'TEST_PROXY'
        assert hasProxy, 'Proxy is not registered'
      .to.not.throw Error
  describe '#lazyRegisterProxy', ->
    facade = null
    INSTANCE_NAME = 'TEST33'
    after ->
      facade?.remove()
    it 'should create new proxy and register it when needed', ->
      co ->
        onRegister = sinon.spy()
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
        facade = Test::Facade.getInstance INSTANCE_NAME
        model = Test::Model.getInstance INSTANCE_NAME
        facade.registerMediator Test::Mediator.new APPLICATION_MEDIATOR, Application.new()
        proxyData = { data: 'data' }
        model.lazyRegisterProxy 'TEST_PROXY', 'TestProxy', proxyData
        assert.isFalse onRegister.called, 'Proxy is already created and registered'
        onRegister.reset()
        hasProxy = model.hasProxy 'TEST_PROXY'
        assert hasProxy, 'Proxy is not registered'
        testProxy = model.retrieveProxy 'TEST_PROXY'
        assert.instanceOf testProxy, TestProxy
        assert onRegister.called, 'Proxy is not registered'
        onRegister.reset()
        yield return
  describe '#removeProxy', ->
    it 'should create new proxy and regiter it, after that remove it', ->
      expect ->
        model = Model.getInstance 'TEST4'
        onRegister = sinon.spy()
        onRemove = sinon.spy()
        class TestProxy extends Proxy
          @inheritProtected()
          @public onRegister: Function,
            default: onRegister
          @public onRemove: Function,
            default: onRemove
        proxyData = { data: 'data' }
        testProxy = TestProxy.new 'TEST_PROXY2', proxyData
        model.registerProxy testProxy
        assert onRegister.called, 'Proxy is not registered'
        hasProxy = model.hasProxy 'TEST_PROXY2'
        assert hasProxy, 'Proxy is not registered'
        onRegister.reset()
        model.removeProxy 'TEST_PROXY2'
        assert onRemove.called, 'Proxy is still registered'
        hasNoProxy = not model.hasProxy 'TEST_PROXY2'
        assert hasNoProxy, 'Proxy is still registered'
      .to.not.throw Error
  describe '#retrieveProxy', ->
    it 'should retrieve registred proxy', ->
      expect ->
        model = Model.getInstance 'TEST5'
        class TestProxy extends Proxy
          @inheritProtected()
        proxyData = { data: 'data' }
        testProxy = TestProxy.new 'TEST_PROXY', proxyData
        model.registerProxy testProxy
        retrievedProxy = model.retrieveProxy 'TEST_PROXY'
        assert retrievedProxy, 'Proxy cannot be retrieved'
        retrievedAbsentProxy = model.retrieveProxy 'TEST_PROXY_ABSENT'
        hasNoAbsentProxy = not retrievedAbsentProxy?
        assert hasNoAbsentProxy, 'Absent proxy can be retrieved'
      .to.not.throw Error
  describe '#hasProxy', ->
    it 'should retrieve registred proxy', ->
      expect ->
        model = Model.getInstance 'TEST6'
        class TestProxy extends Proxy
          @inheritProtected()
        proxyData = { data: 'data' }
        testProxy = TestProxy.new 'TEST_PROXY', proxyData
        model.registerProxy testProxy
        hasProxy = model.hasProxy 'TEST_PROXY'
        assert hasProxy, 'Proxy is absent'
        hasNoAbsentProxy = not model.hasProxy 'TEST_PROXY_ABSENT'
        assert hasNoAbsentProxy, 'Absent proxy is accessible'
      .to.not.throw Error
