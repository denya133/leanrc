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
  describe '#header', ->
    it 'should create endpoint and add header', ->
      expect ->
        gateway = test: 'test'
        endpoint = Endpoint.new { gateway }
        header = name: 'NAME', schema: {}, description: 'DESCRIPTION'
        assert.notInclude endpoint.headers ? [], header, 'Endpoint already contains header'
        endpoint.header header.name, header.schema, header.description
        assert.include endpoint.headers, header, 'Endpoint does not contain header'
      .to.not.throw Error
