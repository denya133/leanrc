{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
RC = require 'RC'
{ co } = RC::Utils

describe 'QueryableCollectionMixin', ->
  describe '.new', ->
    it 'should create queryable instance', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class Test::Queryable extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: LeanRC::Cursor,
            default: (aoParsedQuery) -> yield return aoParsedQuery
        Test::Queryable.initialize()
        queryable = Test::Queryable.new()
        assert.instanceOf queryable, Test::Queryable
        yield return
  describe '#query', ->
    it 'should execute query', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        spyExecuteQuery = sinon.spy (aoParsedQuery) -> yield return aoParsedQuery
        spyParseQuery = sinon.spy (aoQuery) -> aoQuery
        class Test::Queryable extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
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
  describe '#exists', ->
    it 'should check data existance by query', ->
      co ->
        KEY = 'FACADE_TEST_QUERYABLE_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
        Test::TestRecord.initialize()
        class Test::Queryable extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: LeanRC::Cursor,
            default: (aoParsedQuery) ->
              data = _.filter @getData(), aoParsedQuery.$filter
              yield LeanRC::Cursor.new @delegate, data
          @public patch: Function,
            default: (id, item) ->
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record
          @public push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @getData().push record
              yield return record
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
        facade.remove()
        yield return
  describe '#findBy', ->
    it 'should find data by query', ->
      co ->
        KEY = 'FACADE_TEST_QUERYABLE_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::Queryable extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: LeanRC::Cursor,
            default: (aoParsedQuery) ->
              data = _.filter @getData(), aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async patch: Function,
            default: (id, item) ->
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record
          @public @async push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @getData().push yield @delegate.serialize record
              yield return record
          @public @async takeBy: Function,
            default: (query) ->
              voQuery = Test::Query.new()
                .forIn '@doc': @collectionFullName()
                .filter query
                .limit 1
              yield return @query voQuery
        Test::Queryable.initialize()
        collection = Test::Queryable.new KEY, []
        facade.registerProxy collection
        queryable = facade.retrieveProxy KEY
        yield queryable.create test: 'test1'
        yield queryable.create test: 'test2'
        yield queryable.create test: 'test3'
        yield queryable.create test: 'test4'
        record1 = yield (yield queryable.findBy { 'test': 'test2' }).next()
        assert.isDefined record1
        assert.equal record1.test, 'test2'
        record2 = yield (yield queryable.findBy { 'test': 'test5' }).next()
        assert.isUndefined record2
        facade.remove()
        yield return
  describe '#deleteBy', ->
    it 'should mark data as deleted by query', ->
      co ->
        KEY = 'FACADE_TEST_QUERYABLE_004'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::Queryable extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: LeanRC::Cursor,
            default: (aoParsedQuery) ->
              data = _.filter @getData(), aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async patch: Function,
            default: (id, item) ->
              data = _.filter @getData(), { id }
              if _.isArray data
                for datum in data
                  if item.constructor.attributes?
                    vhAttributes = {}
                    for own key of item.constructor.attributes
                      datum[key] = item[key]
                  else
                    datum[key] = value  for own key, value of item
              yield return data.length > 0
          @public @async take: Function,
            default: (id) ->
              data = _.find @getData(), { id }
              throw new Error 'NOT_FOUND'  unless data?
              yield data
          @public @async push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @getData().push yield @delegate.serialize record
              yield return record
          @public @async takeBy: Function,
            default: (query) ->
              voQuery = Test::Query.new()
                .forIn '@doc': @collectionFullName()
                .filter query
                .limit 1
              yield return @query voQuery
          @public @async includes: Function,
            default: (id) -> yield return @exists { id }
          @public @async override: Function,
            default: (id, aoRecord)->
              index = _.findIndex @getData(), { id }
              @getData()[index] = yield @serializer.serialize aoRecord
              yield return Test::Cursor.new(@, [@getData()[index]]).first()
        Test::Queryable.initialize()
        collection = Test::Queryable.new KEY, []
        facade.registerProxy collection
        queryable = facade.retrieveProxy KEY
        yield queryable.create test: 'test1'
        yield queryable.create test: 'test2'
        yield queryable.create test: 'test3'
        yield queryable.create test: 'test2'
        yield queryable.deleteBy { test: 'test2' }
        for rawData in queryable.getData()
          assert.isDefined rawData, 'No specified record'
          if rawData.test is 'test2'
            assert.propertyVal rawData, 'isHidden', yes, 'Record was not removed'
            assert.isNotNull rawData.deletedAt, 'Record deleted data is null'
            assert.isDefined rawData.deletedAt, 'Record deleted data is undefined'
          else
            assert.propertyVal rawData, 'isHidden', no, 'Record was removed'
            assert.isNull rawData.deletedAt, 'Record deleted data is not null'
        facade.remove()
        yield return
  describe '#removeBy', ->
    it 'should remove data by query', ->
      co ->
        KEY = 'FACADE_TEST_QUERYABLE_005'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::Queryable extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: LeanRC::Cursor,
            default: (aoParsedQuery) ->
              data = []
              switch
                when aoParsedQuery['$remove']
                  _.remove @getData(), aoParsedQuery['$filter']
                  yield return
                else
                  data = _.filter @getData(), aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, []
          @public @async patch: Function,
            default: (id, item) ->
              data = _.filter @getData(), { id }
              if _.isArray data
                for datum in data
                  if item.constructor.attributes?
                    vhAttributes = {}
                    for own key of item.constructor.attributes
                      datum[key] = item[key]
                  else
                    datum[key] = value  for own key, value of item
              yield return data.length > 0
          @public @async take: Function,
            default: (id) ->
              data = _.find @getData(), { id }
              throw new Error 'NOT_FOUND'  unless data?
              yield data
          @public @async push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @getData().push yield @delegate.serialize record
              yield return record
        Test::Queryable.initialize()
        collection = Test::Queryable.new KEY, []
        facade.registerProxy collection
        queryable = facade.retrieveProxy KEY
        yield queryable.create test: 'test1'
        yield queryable.create test: 'test2'
        yield queryable.create test: 'test3'
        yield queryable.create test: 'test2'
        yield queryable.removeBy { test: 'test2' }
        data = queryable.getData()
        assert.lengthOf data, 2, 'Records did not removed'
        assert.lengthOf _.filter(data, { test: 'test2' }), 0, 'Found removed records'
        facade.remove()
        yield return
  describe '#destroyBy', ->
    it 'should remove records by query', ->
      co ->
        KEY = 'FACADE_TEST_QUERYABLE_006'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::Queryable extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: LeanRC::Cursor,
            default: (aoParsedQuery) ->
              data = []
              switch
                when aoParsedQuery['$remove']
                  _.remove @getData(), aoParsedQuery['$filter']
                  yield return
                else
                  data = _.filter @getData(), aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async take: Function,
            default: (id) ->
              data = _.find @getData(), { id }
              throw new Error 'NOT_FOUND'  unless data?
              yield data
          @public @async push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @getData().push yield @delegate.serialize record
              yield return record
          @public @async remove: Function,
            default: (id) ->
              _.remove @getData(), { id }
              yield return
          @public @async takeBy: Function,
            default: (query) ->
              voQuery = Test::Query.new()
                .forIn '@doc': @collectionFullName()
                .filter query
                .limit 1
              yield return @query voQuery
          @public @async includes: Function,
            default: (id) -> yield return @exists { id }
        Test::Queryable.initialize()
        collection = Test::Queryable.new KEY, []
        facade.registerProxy collection
        queryable = facade.retrieveProxy KEY
        yield queryable.create test: 'test1'
        yield queryable.create test: 'test2'
        yield queryable.create test: 'test3'
        yield queryable.create test: 'test2'
        yield queryable.destroyBy { test: 'test2' }
        data = queryable.getData()
        assert.lengthOf data, 2, 'Records did not removed'
        assert.lengthOf _.filter(data, { test: 'test2' }), 0, 'Found removed records'
        facade.remove()
        yield return
  describe '#updateBy', ->
    it 'should update data in records by query', ->
      co ->
        KEY = 'FACADE_TEST_QUERYABLE_009'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute updated: Boolean, { default: no }
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::Queryable extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: LeanRC::Cursor,
            default: (aoParsedQuery) ->
              data = _.filter @getData(), aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async patch: Function,
            default: (id, item) ->
              data = _.filter @getData(), { id }
              if _.isArray data
                for datum in data
                  if item.constructor.attributes?
                    vhAttributes = {}
                    for own key of item.constructor.attributes
                      datum[key] = item[key]
                  else
                    datum[key] = value  for own key, value of item
              yield return data.length > 0
          @public @async take: Function,
            default: (id) ->
              data = _.find @getData(), { id }
              throw new Error 'NOT_FOUND'  unless data?
              yield data
          @public @async push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @getData().push yield @delegate.serialize record
              yield return record
          @public @async takeBy: Function,
            default: (query) ->
              voQuery = Test::Query.new()
                .forIn '@doc': @collectionFullName()
                .filter query
                .limit 1
              yield return @query voQuery
          @public @async includes: Function,
            default: (id) -> yield return @exists { id }
          @public @async override: Function,
            default: (id, aoRecord)->
              index = _.findIndex @getData(), { id }
              @getData()[index] = yield @serializer.serialize aoRecord
              yield return Test::Cursor.new(@, [@getData()[index]]).first()
        Test::Queryable.initialize()
        collection = Test::Queryable.new KEY, []
        facade.registerProxy collection
        queryable = facade.retrieveProxy KEY
        yield queryable.create test: 'test1'
        yield queryable.create test: 'test2'
        yield queryable.create test: 'test3'
        yield queryable.create test: 'test2'
        yield queryable.updateBy { test: 'test2' }, { updated: yes }
        for rawData in queryable.getData()
          assert.isDefined rawData, 'No specified record'
          if rawData.test is 'test2'
            assert.propertyVal rawData, 'updated', yes, 'Record was not updated'
          else
            assert.propertyVal rawData, 'updated', no, 'Record was updated'
        facade.remove()
        yield return
  describe '#patchBy', ->
    it 'should update data in records by query', ->
      co ->
        KEY = 'FACADE_TEST_QUERYABLE_010'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute updated: Boolean, { default: no }
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::Queryable extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: LeanRC::Cursor,
            default: (aoParsedQuery) ->
              if (item = aoParsedQuery['$patch'])?
                toBeUpdated = _.filter @getData(), aoParsedQuery.$filter
                if _.isArray toBeUpdated
                  for datum in toBeUpdated
                    if item.constructor.attributes?
                      vhAttributes = {}
                      for own key of item.constructor.attributes
                        datum[key] = item[key]
                    else
                      datum[key] = value  for own key, value of item
              data = _.filter @getData(), aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async take: Function,
            default: (id) ->
              data = _.find @getData(), { id }
              throw new Error 'NOT_FOUND'  unless data?
              yield data
          @public @async push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @getData().push yield @delegate.serialize record
              yield return record
        Test::Queryable.initialize()
        collection = Test::Queryable.new KEY, []
        facade.registerProxy collection
        queryable = facade.retrieveProxy KEY
        yield queryable.create test: 'test1'
        yield queryable.create test: 'test2'
        yield queryable.create test: 'test3'
        yield queryable.create test: 'test2'
        yield queryable.patchBy { test: 'test2' }, { updated: yes }
        for rawData in queryable.getData()
          assert.isDefined rawData, 'No specified record'
          if rawData.test is 'test2'
            assert.propertyVal rawData, 'updated', yes, 'Record was not patched'
          else
            assert.propertyVal rawData, 'updated', no, 'Record was patched'
        facade.remove()
        yield return
