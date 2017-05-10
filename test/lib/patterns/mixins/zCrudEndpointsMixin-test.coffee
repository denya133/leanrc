{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
joi = require 'joi'
LeanRC = require.main.require 'lib'
RC = require 'RC'
{ co } = RC::Utils

describe 'CrudEndpointsMixin', ->
  describe '.new', ->
    it 'should create CRUD gateway instance', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudEndpointsMixin
          @module Test
        TestCrudGateway.initialize()
        gateway = TestCrudGateway.new()
        assert.instanceOf gateway, TestCrudGateway
        yield return
  describe '#keyName', ->
    it 'should get gateway key name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudEndpointsMixin
          @module Test
        TestCrudGateway.initialize()
        gateway = TestCrudGateway.new 'CucumberGateway',
          entityName: 'cucumber'
        { keyName } = gateway
        assert.equal keyName, 'cucumber'
        yield return
  describe '#itemEntityName', ->
    it 'should get gateway item entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudEndpointsMixin
          @module Test
        TestCrudGateway.initialize()
        gateway = TestCrudGateway.new 'CucumberGateway',
          entityName: 'cucumber'
        { itemEntityName } = gateway
        assert.equal itemEntityName, 'cucumber'
        yield return
  describe '#listEntityName', ->
    it 'should get gateway list entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudEndpointsMixin
          @module Test
        TestCrudGateway.initialize()
        gateway = TestCrudGateway.new 'CucumberGateway',
          entityName: 'cucumber'
        { listEntityName } = gateway
        assert.equal listEntityName, 'cucumbers'
        yield return
  describe '#schema', ->
    it 'should get gateway schema', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        TestRecord.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudEndpointsMixin
          @module Test
        TestCrudGateway.initialize()
        gateway = TestCrudGateway.new 'CucumberGateway',
          entityName: 'cucumber'
          schema: TestRecord.schema
        { schema } = gateway
        assert.equal schema, TestRecord.schema
        yield return
  describe '#listSchema', ->
    it 'should get gateway list schema', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        TestRecord.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudEndpointsMixin
          @module Test
        TestCrudGateway.initialize()
        gateway = TestCrudGateway.new 'CucumberGateway',
          entityName: 'cucumber'
          schema: TestRecord.schema
        { listSchema } = gateway
        assert.deepEqual listSchema, joi.object
          cucumbers: joi.array().items TestRecord.schema
        yield return
  describe '#itemSchema', ->
    it 'should get gateway item schema', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        TestRecord.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudEndpointsMixin
          @module Test
        TestCrudGateway.initialize()
        gateway = TestCrudGateway.new 'CucumberGateway',
          entityName: 'cucumber'
          schema: TestRecord.schema
        { itemSchema } = gateway
        assert.deepEqual itemSchema, joi.object
          cucumber: TestRecord.schema
        yield return
  describe '#querySchema', ->
    it 'should get gateway query schema', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        TestRecord.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudEndpointsMixin
          @module Test
        TestCrudGateway.initialize()
        gateway = TestCrudGateway.new 'CucumberGateway',
          entityName: 'cucumber'
          schema: TestRecord.schema
        { querySchema } = gateway
        assert.deepEqual querySchema, joi.string().empty('{}').optional().default '{}', '
          The query for finding objects.
        '
        yield return
  describe '#bulkResponseSchema', ->
    it 'should get gateway bulk response schema', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        TestRecord.initialize()
        class TestCrudGateway extends LeanRC::Gateway
          @inheritProtected()
          @include LeanRC::CrudEndpointsMixin
          @module Test
        TestCrudGateway.initialize()
        gateway = TestCrudGateway.new 'CucumberGateway',
          entityName: 'cucumber'
          schema: TestRecord.schema
        { bulkResponseSchema } = gateway
        assert.deepEqual bulkResponseSchema, joi.object success: joi.boolean()
        yield return
