{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{
  NilT
  FuncG
  CollectionInterface
  Utils: { co } 
} = LeanRC::

describe 'MemoryCollectionMixin', ->
  describe '.new', ->
    it 'should create HTTP collection instance', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: FuncG([Object, CollectionInterface], NilT),
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestRecord'
          @initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = MemoryCollection.new 'MemoryCollection',
          delegate: 'TestRecord'
        assert.instanceOf collection, MemoryCollection
        yield return
  describe '#push', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should put data into collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          # @public init: FuncG([Object, CollectionInterface], NilT),
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestRecord'
          #     return
          @initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        facade.registerProxy MemoryCollection.new KEY,
          delegate: 'TestRecord'
        collection = facade.retrieveProxy KEY
        spyPush = sinon.spy collection, 'push'
        assert.instanceOf collection, MemoryCollection
        record = TestRecord.new {test: 'test1', type: 'Test::TestRecord'}, collection
        record.id = yield collection.generateId()
        yield collection.push record
        assert.equal record, spyPush.args[0][0]
        assert.deepEqual record.toJSON(), collection[Symbol.for '~collection'][record.id]
        yield return
  describe '#remove', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should remove data from collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: FuncG([Object, CollectionInterface], NilT),
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
              return
          @initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        facade.registerProxy MemoryCollection.new KEY,
          delegate: 'TestRecord'
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, MemoryCollection
        record = yield collection.create test: 'test1'
        assert.deepEqual record.toJSON(), collection[Symbol.for '~collection'][record.id]
        yield record.destroy()
        assert.isUndefined collection[Symbol.for '~collection'][record.id]
        yield return
  describe '#take', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get data item by id from collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: FuncG([Object, CollectionInterface], NilT),
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
              return
          @initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        facade.registerProxy MemoryCollection.new KEY,
          delegate: 'TestRecord'
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, MemoryCollection
        record = yield collection.create test: 'test1'
        recordDuplicate = yield collection.take record.id
        assert.notEqual record, recordDuplicate
        for attribute in TestRecord.attributes
          assert.equal record[attribute], recordDuplicate[attribute]
        yield return
  describe '#takeMany', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get data items by id list from collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_004'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: FuncG([Object, CollectionInterface], NilT),
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
              return
          @initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        facade.registerProxy MemoryCollection.new KEY,
          delegate: 'TestRecord'
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, MemoryCollection
        originalRecords = []
        for i in [ 1 .. 5 ]
          originalRecords.push yield collection.create test: 'test1'
        ids = originalRecords.map (item) -> item.id
        recordDuplicates = yield (yield collection.takeMany ids).toArray()
        assert.equal originalRecords.length, recordDuplicates.length
        count = originalRecords.length
        for i in [ 1 .. count ]
          for attribute in TestRecord.attributes
            assert.equal originalRecords[i][attribute], recordDuplicates[i][attribute]
        yield return
  describe '#takeAll', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get all data items from collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_005'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: FuncG([Object, CollectionInterface], NilT),
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
              return
          @initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        facade.registerProxy MemoryCollection.new KEY,
          delegate: 'TestRecord'
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, MemoryCollection
        originalRecords = []
        for i in [ 1 .. 5 ]
          originalRecords.push yield collection.create test: 'test1'
        recordDuplicates = yield (yield collection.takeAll()).toArray()
        assert.equal originalRecords.length, recordDuplicates.length
        count = originalRecords.length
        for i in [ 1 .. count ]
          for attribute in TestRecord.attributes
            assert.equal originalRecords[i][attribute], recordDuplicates[i][attribute]
        yield return
  describe '#override', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should replace data item by id in collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_006'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: FuncG([Object, CollectionInterface], NilT),
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
              return
          @initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        facade.registerProxy MemoryCollection.new KEY,
          delegate: 'TestRecord'
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, MemoryCollection
        record = yield collection.create test: 'test1'
        raw = yield collection.build(
          id: record.id
          test: 'test2'
        )
        updatedRecord = yield collection.override record.id, raw
        assert.isDefined updatedRecord
        assert.equal record.id, updatedRecord.id
        assert.propertyVal record, 'test', 'test1'
        assert.propertyVal updatedRecord, 'test', 'test2'
        yield return
  describe '#includes', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should test if item is included in the collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_008'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: FuncG([Object, CollectionInterface], NilT),
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
              return
          @initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        facade.registerProxy MemoryCollection.new KEY,
          delegate: 'TestRecord'
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, MemoryCollection
        record = yield collection.create test: 'test1'
        assert.isDefined record
        includes = yield collection.includes record.id
        assert.isTrue includes
        yield return
  describe '#length', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should count items in the collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_009'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: FuncG([Object, CollectionInterface], NilT),
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
              return
          @initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        facade.registerProxy MemoryCollection.new KEY,
          delegate: 'TestRecord'
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, MemoryCollection
        count = 11
        for i in [ 1 .. count ]
          yield collection.create test: 'test1'
        length = yield collection.length()
        assert.equal count, length
        yield return
