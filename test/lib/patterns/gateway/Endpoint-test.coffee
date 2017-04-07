{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Endpoint = LeanRC::Endpoint

describe 'Endpoint', ->
  describe '.new', ->
    it 'should create new endpoint', ->
      expect ->
        gateway = test: 'test'
        endpoint = Endpoint.new { gateway }
        assert.equal endpoint.gateway, gateway, 'Gateway is incorrect'
      .to.not.throw Error
