{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
joi = require 'joi'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'CrudEndpointMixin', ->
  describe '.new', ->
    it 'should create CRUD endpoint instance', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestCrudEndpoint extends LeanRC::Endpoint
          @inheritProtected()
          @include LeanRC::CrudEndpointMixin
          @module Test
        TestCrudEndpoint.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudGatewayMixin
          @module Test
        TestCrudGateway.initialize()
        endpoint = TestCrudEndpoint.new
          gateway: TestCrudGateway.new 'CucumberGateway',
            entityName: 'cucumber'
        assert.instanceOf endpoint, TestCrudEndpoint
        yield return
  describe '#keyName', ->
    it 'should get endpoint key name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestCrudEndpoint extends LeanRC::Endpoint
          @inheritProtected()
          @include LeanRC::CrudEndpointMixin
          @module Test
        TestCrudEndpoint.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudGatewayMixin
          @module Test
        TestCrudGateway.initialize()
        endpoint = TestCrudEndpoint.new
          gateway: TestCrudGateway.new 'CucumberGateway',
            entityName: 'cucumber'
        { keyName } = endpoint
        assert.equal keyName, 'cucumber'
        yield return
  describe '#itemEntityName', ->
    it 'should get endpoint item entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestCrudEndpoint extends LeanRC::Endpoint
          @inheritProtected()
          @include LeanRC::CrudEndpointMixin
          @module Test
        TestCrudEndpoint.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudGatewayMixin
          @module Test
        TestCrudGateway.initialize()
        endpoint = TestCrudEndpoint.new
          gateway: TestCrudGateway.new 'CucumberGateway',
            entityName: 'cucumber'
        { itemEntityName } = endpoint
        assert.equal itemEntityName, 'cucumber'
        yield return
  describe '#listEntityName', ->
    it 'should get endpoint list entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestCrudEndpoint extends LeanRC::Endpoint
          @inheritProtected()
          @include LeanRC::CrudEndpointMixin
          @module Test
        TestCrudEndpoint.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudGatewayMixin
          @module Test
        TestCrudGateway.initialize()
        endpoint = TestCrudEndpoint.new
          gateway: TestCrudGateway.new 'CucumberGateway',
            entityName: 'cucumber'
        { listEntityName } = endpoint
        assert.equal listEntityName, 'cucumbers'
        yield return
  describe '#schema', ->
    it 'should get endpoint schema', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        TestRecord.initialize()
        class TestCrudEndpoint extends LeanRC::Endpoint
          @inheritProtected()
          @include LeanRC::CrudEndpointMixin
          @module Test
        TestCrudEndpoint.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudGatewayMixin
          @module Test
        TestCrudGateway.initialize()
        endpoint = TestCrudEndpoint.new
          gateway: TestCrudGateway.new 'CucumberGateway',
            entityName: 'cucumber'
            schema: TestRecord.schema
        { schema } = endpoint
        assert.equal schema, TestRecord.schema
        yield return
  describe '#listSchema', ->
    it 'should get endpoint list schema', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        TestRecord.initialize()
        class TestCrudEndpoint extends LeanRC::Endpoint
          @inheritProtected()
          @include LeanRC::CrudEndpointMixin
          @module Test
        TestCrudEndpoint.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudGatewayMixin
          @module Test
        TestCrudGateway.initialize()
        endpoint = TestCrudEndpoint.new
          gateway: TestCrudGateway.new 'CucumberGateway',
            entityName: 'cucumber'
            schema: TestRecord.schema
        { listSchema } = endpoint
        assert.deepEqual listSchema, joi.object
          cucumbers: joi.array().items TestRecord.schema
        yield return
  describe '#itemSchema', ->
    it 'should get endpoint item schema', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        TestRecord.initialize()
        class TestCrudEndpoint extends LeanRC::Endpoint
          @inheritProtected()
          @include LeanRC::CrudEndpointMixin
          @module Test
        TestCrudEndpoint.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudGatewayMixin
          @module Test
        TestCrudGateway.initialize()
        endpoint = TestCrudEndpoint.new
          gateway: TestCrudGateway.new 'CucumberGateway',
            entityName: 'cucumber'
            schema: TestRecord.schema
        { itemSchema } = endpoint
        assert.deepEqual itemSchema, joi.object
          cucumber: TestRecord.schema
        yield return
  describe '#querySchema', ->
    it 'should get endpoint query schema', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        TestRecord.initialize()
        class TestCrudEndpoint extends LeanRC::Endpoint
          @inheritProtected()
          @include LeanRC::CrudEndpointMixin
          @module Test
        TestCrudEndpoint.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudGatewayMixin
          @module Test
        TestCrudGateway.initialize()
        endpoint = TestCrudEndpoint.new
          gateway: TestCrudGateway.new 'CucumberGateway',
            entityName: 'cucumber'
            schema: TestRecord.schema
        { querySchema } = endpoint
        assert.deepEqual querySchema, joi.string().empty('{}').optional().default '{}', '
          The query for finding objects.
        '
        yield return
  describe '#bulkResponseSchema', ->
    it 'should get endpoint bulk response schema', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        TestRecord.initialize()
        class TestCrudEndpoint extends LeanRC::Endpoint
          @inheritProtected()
          @include LeanRC::CrudEndpointMixin
          @module Test
        TestCrudEndpoint.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudGatewayMixin
          @module Test
        TestCrudGateway.initialize()
        endpoint = TestCrudEndpoint.new
          gateway: TestCrudGateway.new 'CucumberGateway',
            entityName: 'cucumber'
            schema: TestRecord.schema
        { bulkResponseSchema } = endpoint
        assert.deepEqual bulkResponseSchema, joi.object success: joi.boolean()
        yield return
  describe '#versionSchema', ->
    it 'should get endpoint version schema', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        TestRecord.initialize()
        class TestCrudEndpoint extends LeanRC::Endpoint
          @inheritProtected()
          @include LeanRC::CrudEndpointMixin
          @module Test
        TestCrudEndpoint.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudGatewayMixin
          @module Test
        TestCrudGateway.initialize()
        endpoint = TestCrudEndpoint.new
          gateway: TestCrudGateway.new 'CucumberGateway',
            entityName: 'cucumber'
            schema: TestRecord.schema
        { versionSchema } = endpoint
        assert.deepEqual versionSchema, joi.string().required().description '
          The version of api endpoint in format `vx.x`
        '
        yield return
