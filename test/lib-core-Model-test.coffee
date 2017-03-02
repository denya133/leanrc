{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require '../lib'
Model = LeanRC::Model
Proxy = LeanRC::Proxy

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
    it 'should create new proxy and regiter it', ->
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
