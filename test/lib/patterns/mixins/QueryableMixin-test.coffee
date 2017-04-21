{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
RC = require 'RC'
{ co } = RC::Utils

describe 'QueryableMixin', ->
  describe '.new', ->
    it 'should create queryable instance', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        # class Test::TestRecord extends LeanRC::Record
        #   @inheritProtected()
        #   @Module: Test
        # Test::TestRecord.initialize()
        class Test::Queryable extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @Module: Test
          @public parseQuery: Object,
            default: (aoQuery) ->
          @public @async executeQuery: LeanRC::Cursor,
            default: (aoParsedQuery) -> yield return
        Test::Queryable.initialize()
        queryable = Test::Queryable.new()# Test::TestRecord, array
        assert.instanceOf queryable, Test::Queryable
        yield return
