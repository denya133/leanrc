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
  describe '#tag', ->
    it 'should create endpoint and add tag', ->
      expect ->
        gateway = test: 'test'
        endpoint = Endpoint.new { gateway }
        tag = 'ENDPOINT_TAG'
        assert.notInclude endpoint.tags ? [], tag, 'Endpoint already contains tag'
        endpoint.tag tag
        assert.include endpoint.tags, tag, 'Endpoint does not contain tag'
      .to.not.throw Error
