{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require '../lib'
Notification = LeanRC::Notification
Proxy = LeanRC::Proxy

describe 'Proxy', ->
  describe '.new', ->
    it 'should create new proxy', ->
      expect ->
        proxy = Proxy.new 'TEST_PROXY', {}
      .to.not.throw Error
