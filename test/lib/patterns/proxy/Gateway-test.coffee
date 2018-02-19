{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{
  Gateway,
  Utils: { co, joi }
} = LeanRC::

describe 'Gateway', ->
  describe '.new', ->
    it 'should create new gateway', ->
      co ->
        gateway = Gateway.new 'TEST_GATEWAY', endpoints: {}
        yield return
  ###
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
  ###
  describe '#swaggerDefinitionFor', ->
    it 'should get swagger definition for action', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/lib"
          @initialize()
        class ApplicationGateway extends Gateway
          @inheritProtected()
          @module Test
          @initialize()
        gateway = ApplicationGateway.new 'TEST_GATEWAY'
        voEndpointForDetailAction = gateway.swaggerDefinitionFor 'test', 'detail',
          keyName: 'test'
          entityName: 'test'
          recordName: null
        , yes
        assert.instanceOf voEndpointForDetailAction, Test::DetailEndpoint
        voEndpointForUndoAction = gateway.swaggerDefinitionFor 'test', 'undo',
          keyName: 'test'
          entityName: 'test'
          recordName: null
        , yes
        assert.isDefined Test::TestUndoEndpoint
        assert.instanceOf voEndpointForUndoAction, Test::TestUndoEndpoint
        voEndpointForTestAction = gateway.swaggerDefinitionFor 'test/', 'test',
          keyName: 'test'
          entityName: 'test'
          recordName: null
        , no
        assert.isDefined Test::TestTestEndpoint
        assert.instanceOf voEndpointForTestAction, Test::TestTestEndpoint
        voEndpointForAnyAction = gateway.swaggerDefinitionFor 'test', 'any',
          keyName: 'test'
          entityName: 'test'
          recordName: null
        , no
        assert.instanceOf voEndpointForAnyAction, Test::Endpoint
        voEndpointForTestListAction = gateway.swaggerDefinitionFor 'test', 'list',
          keyName: 'test'
          entityName: 'test'
          recordName: null
        , no
        assert.instanceOf voEndpointForTestListAction, Test::TestListEndpoint
        yield return
  ###
  describe '#onRegister', ->
    it 'should test register as proxy', ->
      co ->
        endpoints =
          list: LeanRC::Endpoint
          detail: LeanRC::Endpoint
          patch: LeanRC::Endpoint
        gateway = Gateway.new 'TEST_GATEWAY', {endpoints}
        gateway.onRegister()
        listDefinition = gateway.swaggerDefinitionFor 'list'
        detailDefinition = gateway.swaggerDefinitionFor 'detail'
        patchDefinition = gateway.swaggerDefinitionFor 'patch'
        assert.equal listDefinition?.constructor, endpoints.list, 'No `list` endpoint created'
        assert.equal detailDefinition?.constructor, endpoints.detail, 'No `detail` endpoint created'
        assert.equal patchDefinition?.constructor, endpoints.patch, 'No `patch` endpoint created'
        yield return
  ###
