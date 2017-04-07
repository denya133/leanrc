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
  describe '#swaggerDefinition', ->
    it 'should create swagger definition for action', ->
      expect ->
        gateway = Gateway.new 'TEST_GATEWAY'
        voEndpoint = null
        gateway.swaggerDefinition 'list', (aoEndpoint) ->
          voEndpoint = aoEndpoint
          aoEndpoint
        assert.instanceOf voEndpoint, LeanRC::Endpoint, 'No endpoint created'
      .to.not.throw Error
  describe '#swaggerDefinitionFor', ->
    it 'should get swagger definition for action', ->
      expect ->
        gateway = Gateway.new 'TEST_GATEWAY'
        voEndpoint = null
        gateway.swaggerDefinition 'list', (aoEndpoint) ->
          voEndpoint = aoEndpoint
          aoEndpoint
        voEndpointForAction = gateway.swaggerDefinitionFor 'list'
        assert.equal voEndpoint, voEndpointForAction, 'No endpoint created'
      .to.not.throw Error
