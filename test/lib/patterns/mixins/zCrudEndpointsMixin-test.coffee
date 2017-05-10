{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
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
    it 'should gateway key name', ->
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
