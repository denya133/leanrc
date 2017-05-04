{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'MemoryCollectionMixin', ->
  describe '.new', ->
    it 'should create HTTP collection instance', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::MemoryCollection.initialize()
        collection = Test::MemoryCollection.new()
        assert.instanceOf collection, Test::MemoryCollection
        yield return
  describe '#push', ->
    it 'should put data into collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::MemoryCollection.initialize()
        facade.registerProxy Test::MemoryCollection.new KEY,
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
        collection = facade.retrieveProxy KEY
        spyPush = sinon.spy collection, 'push'
        assert.instanceOf collection, Test::MemoryCollection
        record = Test::TestRecord.new test: 'test1', collection
        record._key = collection.generateId()
        yield collection.push record
        assert.equal record, spyPush.args[0][0]
        assert.deepEqual record.toJSON(), collection[Symbol.for '~collection'][record.id]
        yield return
  describe '#remove', ->
    it 'should remove data from collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::MemoryCollection.initialize()
        facade.registerProxy Test::MemoryCollection.new KEY,
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, Test::MemoryCollection
        record = yield collection.create test: 'test1'
        assert.deepEqual record.toJSON(), collection[Symbol.for '~collection'][record.id]
        yield record.destroy()
        assert.isUndefined collection[Symbol.for '~collection'][record.id]
        yield return
  describe '#take', ->
    it 'should get data item by id from collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_004'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::MemoryCollection.initialize()
        facade.registerProxy Test::MemoryCollection.new KEY,
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, Test::MemoryCollection
        record = yield collection.create test: 'test1'
        recordDuplicate = yield collection.take record.id
        assert.notEqual record, recordDuplicate
        for attribute in Test::TestRecord.attributes
          assert.equal record[attribute], recordDuplicate[attribute]
        yield return
  describe '#takeMany', ->
    it 'should get data items by id list from collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_005'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::MemoryCollection.initialize()
        facade.registerProxy Test::MemoryCollection.new KEY,
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, Test::MemoryCollection
        originalRecords = []
        for i in [ 1 .. 5 ]
          originalRecords.push yield collection.create test: 'test1'
        ids = originalRecords.map (item) -> item.id
        recordDuplicates = yield (yield collection.takeMany ids).toArray()
        assert.equal originalRecords.length, recordDuplicates.length
        count = originalRecords.length
        for i in [ 1 .. count ]
          for attribute in Test::TestRecord.attributes
            assert.equal originalRecords[i][attribute], recordDuplicates[i][attribute]
        yield return
  describe '#takeAll', ->
    it 'should get all data items from collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_006'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::MemoryCollection.initialize()
        facade.registerProxy Test::MemoryCollection.new KEY,
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, Test::MemoryCollection
        originalRecords = []
        for i in [ 1 .. 5 ]
          originalRecords.push yield collection.create test: 'test1'
        recordDuplicates = yield (yield collection.takeAll()).toArray()
        assert.equal originalRecords.length, recordDuplicates.length
        count = originalRecords.length
        for i in [ 1 .. count ]
          for attribute in Test::TestRecord.attributes
            assert.equal originalRecords[i][attribute], recordDuplicates[i][attribute]
        yield return
  describe '#override', ->
    it 'should replace data item by id in collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_007'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::MemoryCollection.initialize()
        facade.registerProxy Test::MemoryCollection.new KEY,
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, Test::MemoryCollection
        record = yield collection.create test: 'test1'
        raw = collection.build
          _key: record.id
          test: 'test2'
        updatedRecord = yield (yield collection.override record.id, raw).first()
        assert.isDefined updatedRecord
        assert.equal record.id, updatedRecord.id
        assert.propertyVal record, 'test', 'test1'
        assert.propertyVal updatedRecord, 'test', 'test2'
        yield return
  ###
  describe '#patch', ->
    it 'should update data item by id in collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_008'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::MemoryCollection.initialize()
        facade.registerProxy Test::MemoryCollection.new KEY,
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, Test::MemoryCollection
        record = yield collection.create test: 'test1'
        updatedRecord = yield collection.patch record.id, collection.build test: 'test2'
        assert.isDefined updatedRecord
        assert.equal record.id, updatedRecord.id
        assert.propertyVal record, 'test', 'test1'
        assert.propertyVal updatedRecord, 'test', 'test2'
        yield return
  describe '#includes', ->
    it 'should test if item is included in the collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_009'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::MemoryCollection.initialize()
        facade.registerProxy Test::MemoryCollection.new KEY,
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, Test::MemoryCollection
        record = yield collection.create test: 'test1'
        assert.isDefined record
        includes = yield collection.includes record.id
        assert.isTrue includes
        yield return
  describe '#length', ->
    it 'should count items in the collection', ->
      co ->
        KEY = 'FACADE_TEST_MEMORY_COLLECTION_010'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::MemoryCollection.initialize()
        facade.registerProxy Test::MemoryCollection.new KEY,
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, Test::MemoryCollection
        count = 11
        for i in [ 1 .. count ]
          yield collection.create test: 'test1'
        length = yield collection.length()
        assert.equal count, length
        yield return
  ###
