{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Proxy = LeanRC::Proxy

describe 'Proxy', ->
  describe '.new', ->
    it 'should create new proxy', ->
      expect ->
        proxy = Proxy.new 'TEST_PROXY', {}
      .to.not.throw Error
  describe '#getProxyName', ->
    it 'should get proxy name', ->
      proxy = Proxy.new 'TEST_PROXY', {}
      expect proxy.getProxyName()
      .to.equal 'TEST_PROXY'
  describe '#getData', ->
    it 'should get proxy data', ->
      name = 'TEST_PROXY'
      data = { data: 'getData' }
      proxy = Proxy.new name, data
      expect proxy.getData()
      .to.equal data
  describe '#setData', ->
    it 'should set proxy data', ->
      name = 'TEST_PROXY'
      data = { data: 'setData' }
      proxy = Proxy.new name
      proxy.setData data
      expect proxy.getData()
      .to.equal data
  describe '#onRegister', ->
    it 'should have onRegister function', ->
      expect ->
        name = 'TEST_PROXY'
        proxy = Proxy.new name
        onRegister = sinon.spy proxy, 'onRegister'
        proxy.onRegister()
        assert onRegister.called, 'Proxy.onRegister was not called'
      .to.not.throw Error
  describe '#onRemove', ->
    it 'should have onRemove function', ->
      expect ->
        name = 'TEST_PROXY'
        proxy = Proxy.new name
        onRemove = sinon.spy proxy, 'onRemove'
        proxy.onRemove()
        assert onRemove.called, 'Proxy.onRemove was not called'
      .to.not.throw Error
