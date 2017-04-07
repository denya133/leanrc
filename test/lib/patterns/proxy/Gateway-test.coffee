{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Gateway = LeanRC::Gateway

describe 'Gateway', ->
  describe '.new', ->
    it 'should create new gateway', ->
      expect ->
        gateway = Gateway.new 'TEST_GATEWAY', endpoints: {}
      .to.not.throw Error
