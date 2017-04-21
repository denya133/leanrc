{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
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
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: LeanRC::Cursor,
            default: (aoParsedQuery) -> yield return aoParsedQuery
        Test::Queryable.initialize()
        queryable = Test::Queryable.new()# Test::TestRecord, array
        assert.instanceOf queryable, Test::Queryable
        yield return
  describe '#query', ->
    it 'should execute query', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        # class Test::TestRecord extends LeanRC::Record
        #   @inheritProtected()
        #   @Module: Test
        # Test::TestRecord.initialize()
        spyExecuteQuery = sinon.spy (aoParsedQuery) -> yield return aoParsedQuery
        spyParseQuery = sinon.spy (aoQuery) -> aoQuery
        class Test::Queryable extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @Module: Test
          @public parseQuery: Object,
            default: spyParseQuery
          @public @async executeQuery: LeanRC::Cursor,
            default: spyExecuteQuery
        Test::Queryable.initialize()
        queryable = Test::Queryable.new()# Test::TestRecord, array
        query = { test: 'test' }
        yield queryable.query query
        assert.isTrue spyParseQuery.calledWith(query)
        assert.isTrue spyExecuteQuery.calledWith(query)
        yield return
  describe '#takeBy', ->
    it 'should get data by query', ->
      co ->
        KEY = 'FACADE_TEST_QUERYABLE_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
          @attribute test: String
        Test::TestRecord.initialize()
        class Test::Queryable extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: LeanRC::Cursor,
            default: (aoParsedQuery) -> yield _.filter @getData(), aoParsedQuery.$filter
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
          # @public take: Function,
          #   default: (id) -> yield _.find @getData(), { id }
          @public push: Function,
            default: (record) ->
              record._key = RC::Utils.uuid.v4()
              @getData().push record
              yield return
        Test::Queryable.initialize()
        collection = Test::Queryable.new KEY, []
        facade.registerProxy collection
        queryable = facade.retrieveProxy KEY
        yield queryable.create test: 'test1'
        yield queryable.create test: 'test2'
        yield queryable.create test: 'test3'
        yield queryable.create test: 'test4'
        [ record1 ] = yield queryable.takeBy { test: 'test2' }
        [ record2 ] = yield queryable.takeBy { test: 'test5' }
        assert.isDefined record1
        assert.equal record1.test, 'test2'
        assert.isUndefined record2
        yield return
  describe '#exists', ->
    it 'should check data existance by query', ->
      co ->
        KEY = 'FACADE_TEST_QUERYABLE_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
          @attribute test: String
        Test::TestRecord.initialize()
        class Test::Queryable extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: LeanRC::Cursor,
            default: (aoParsedQuery) ->
              data = _.filter @getData(), aoParsedQuery.$filter
              yield LeanRC::Cursor.new @delegate, data
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
          # @public take: Function,
          #   default: (id) -> yield _.find @getData(), { id }
          @public push: Function,
            default: (record) ->
              record._key = RC::Utils.uuid.v4()
              @getData().push record
              yield return
        Test::Queryable.initialize()
        collection = Test::Queryable.new KEY, []
        facade.registerProxy collection
        queryable = facade.retrieveProxy KEY
        yield queryable.create test: 'test1'
        yield queryable.create test: 'test2'
        yield queryable.create test: 'test3'
        yield queryable.create test: 'test4'
        assert.isTrue yield queryable.exists { test: 'test2' }
        assert.isFalse yield queryable.exists { test: 'test5' }
        yield return
