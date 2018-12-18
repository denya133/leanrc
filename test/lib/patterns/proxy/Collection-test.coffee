{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{
  NilT
  FuncG
  NotificationInterface, CollectionInterface
  Utils: { co }
} = LeanRC::


describe 'Collection', ->
  facade = null
  afterEach ->
    facade?.remove?()
  describe '.new', ->
    it 'should create collection instance', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        assert.equal collection.delegate, TestRecord, 'Record is incorrect'
        assert.deepEqual collection.serializer, LeanRC::Serializer.new(collection), 'Serializer is incorrect'
        assert.deepEqual collection.objectizer, LeanRC::Objectizer.new(collection), 'Objectizer is incorrect'
        yield return
  describe '#collectionName', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get collection name', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        assert.equal collection.collectionName(), 'tests'
        yield return
  describe '#collectionPrefix', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get collection prefix', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        assert.equal collection.collectionPrefix(), 'test_'
        yield return
  describe '#collectionFullName', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get collection full name', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_004'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        assert.equal collection.collectionFullName(), 'test_tests'
        yield return
  describe '#recordHasBeenChanged', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should send notification about record changed', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_005'
        facade = LeanRC::Facade.getInstance KEY
        spyHandleNotitfication = sinon.spy ->
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        class TestMediator extends LeanRC::Mediator
          @inheritProtected()
          @module Test
          @public listNotificationInterests: FuncG([], Array),
            default: -> [ LeanRC::RECORD_CHANGED ]
          @public handleNotification: FuncG(NotificationInterface, NilT),
            default: spyHandleNotitfication
          @initialize()
        # facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_01'
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        # collection = facade.retrieveProxy 'TEST_COLLECTION'
        facade.registerMediator TestMediator.new 'TEST_MEDIATOR', {}
        mediator = facade.retrieveMediator 'TEST_MEDIATOR'
        collection.recordHasBeenChanged 'createdRecord', TestRecord.new({ test: 'test', type: 'Test::TestRecord'}, collection)
        assert.isTrue spyHandleNotitfication.called, 'Notification did not received'
        yield return
  describe '#generateId', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get dummy generated ID', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_006'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          # @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        assert.isUndefined yield collection.generateId(), 'Generated ID is defined'
        yield return
  describe '#build', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should create record from delegate', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_007'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        record = yield collection.build test: 'test', data: 123
        assert.equal record.test, 'test', 'Record#test is incorrect'
        assert.equal record.data, 123, 'Record#data is incorrect'
        yield return
  describe '#create', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should create record in collection', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_008'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        spyCollectionPush = sinon.spy collection, 'push'
        # facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_FACADE_01'
        # facade.registerProxy collection
        record = yield collection.create test: 'test', data: 123
        assert.isDefined record, 'Record not created'
        assert.isTrue spyCollectionPush.called, 'Record not saved'
        yield return
  describe '#update', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should update record in collection', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_009'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        record = yield collection.create test: 'test', data: 123
        record.data = 456
        yield record.update()
        assert.equal (yield collection.find record.id).data, 456, 'Record not updated'
        yield return
  describe '#delete', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should delete record from collection', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_010'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        record = yield collection.create test: 'test', data: 123
        yield record.delete()
        assert.isFalse yield record.isNew(), 'Record not saved'
        assert.isTrue record.isHidden, 'Record not hidden'
        yield return
  describe '#destroy', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should destroy record from collection', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_011'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        record = yield collection.create test: 'test', data: 123
        yield record.destroy()
        assert.isFalse (yield collection.find record.id)?, 'Record removed'
        yield return
  describe '#find', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should find record from collection', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_012'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        record = yield collection.create test: 'test', data: 123
        record2 = yield collection.find record.id
        assert.equal record.test, record2.test, 'Record not found'
        yield return
  describe '#findMany', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should find many records from collection', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_013'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        { id: id1 } = yield collection.create test: 'test1'
        { id: id2 } = yield collection.create test: 'test2'
        { id: id3 } = yield collection.create test: 'test3'
        records = yield (yield collection.findMany [ id1, id2, id3 ]).toArray()
        assert.equal records.length, 3, 'Found not the three records'
        assert.equal records[0].test, 'test1', 'First record is incorrect'
        assert.equal records[1].test, 'test2', 'Second record is incorrect'
        assert.equal records[2].test, 'test3', 'Third record is incorrect'
        yield return
  describe '#clone', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should make record copy with new id without save', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_014'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestRecord'
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        original = yield collection.build test: 'test', data: 123
        clone = yield collection.clone original
        assert.notEqual original, clone, 'Record is not a copy but a reference'
        assert.equal original.test, clone.test, '`test` values are different'
        assert.equal original.data, clone.data, '`data` values are different'
        assert.notEqual original.id, clone.id, '`id` values are the same'
        yield return
  describe '#copy', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should make record copy with new id with save', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_015'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          # @public init: Function,
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestRecord'
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
        facade.registerProxy collection
        original = yield collection.build test: 'test', data: 123
        clone = yield collection.copy original
        assert.notEqual original, clone, 'Record is not a copy but a reference'
        assert.equal original.test, clone.test, '`test` values are different'
        assert.equal original.data, clone.data, '`data` values are different'
        assert.notEqual original.id, clone.id, '`id` values are the same'
        yield return
  describe '#normalize', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should normalize record from data', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_016'
        facade = LeanRC::Facade.getInstance KEY
        spySerializerNormalize = sinon.spy (acRecord, ahPayload)->
          self = @
          co ->
            return yield acRecord.normalize ahPayload, self.collection
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          # @public init: FuncG([Object, CollectionInterface], NilT),
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestRecord'
          #     return
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        class TestSerializer extends LeanRC::Serializer
          @inheritProtected()
          @module Test
          @initialize()
        Reflect.defineProperty TestSerializer::, 'normalize',
          value: spySerializerNormalize
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
          serializer: TestSerializer
        facade.registerProxy collection


        # collection = Test::TestsCollection.new 'TEST_COLLECTION',
        #   delegate: Test::TestRecord
        #   serializer: class Serializer
        #     @new: (args) -> Reflect.construct @, args
        #     normalize: spySerializerNormalize
        # # facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_FACADE_11'
        # facade.registerProxy collection
        record = yield collection.normalize test: 'test', data: 123, type: 'Test::TestRecord'
        assert.isTrue spySerializerNormalize.calledWith(TestRecord, test: 'test', data: 123, type: 'Test::TestRecord'), 'Normalize called improperly'
        yield return
  describe '#serialize', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should serialize record to data', ->
      co ->
        collectionName = 'TestsCollection'
        KEY = 'TEST_COLLECTION_017'
        facade = LeanRC::Facade.getInstance KEY
        spySerializerSerialize = sinon.spy (aoRecord, options = null)->
          co ->
            vcRecord = aoRecord.constructor
            return yield vcRecord.serialize aoRecord, options
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        class TestSerializer extends LeanRC::Serializer
          @inheritProtected()
          @module Test
          @initialize()
        Reflect.defineProperty TestSerializer::, 'serialize',
          value: spySerializerSerialize
        collection = TestsCollection.new collectionName,
          delegate: 'TestRecord'
          serializer: TestSerializer
        facade.registerProxy collection


        # collection = Test::TestsCollection.new 'TEST_COLLECTION',
        #   delegate: Test::TestRecord
        #   serializer: class Serializer
        #     @new: (args) -> Reflect.construct @, args
        #     serialize: spySerializerSerialize
        # # facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_FACADE_12'
        # facade.registerProxy collection
        record = yield collection.build test: 'test', data: 123
        data = yield collection.serialize record, value: 'value'
        assert.isTrue spySerializerSerialize.calledWith(record, value: 'value'), 'Serialize called improperly'
        yield return
