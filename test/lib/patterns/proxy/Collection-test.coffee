{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'Collection', ->
  describe '.new', ->
    it 'should create collection instance', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'COLLECTION',
          delegate: Test::TestRecord
        assert.equal collection.delegate, Test::TestRecord, 'Record is incorrect'
        yield return
  describe '#collectionName', ->
    it 'should get collection name', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'COLLECTION',
          delegate: Test::TestRecord
        assert.equal collection.collectionName(), 'tests'
        yield return
  describe '#collectionPrefix', ->
    it 'should get collection prefix', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'COLLECTION',
          delegate: Test::TestRecord
        assert.equal collection.collectionPrefix(), 'test_'
        yield return
  describe '#collectionFullName', ->
    it 'should get collection full name', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'COLLECTION',
          delegate: Test::TestRecord
        assert.equal collection.collectionFullName(), 'test_tests'
        yield return
  describe '#recordHasBeenChanged', ->
    it 'should send notification about record changed', ->
      co ->
        spyHandleNotitfication = sinon.spy ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        class Test::TestMediator extends LeanRC::Mediator
          @inheritProtected()
          @module Test
          @public listNotificationInterests: Function,
            default: -> [ LeanRC::RECORD_CHANGED ]
          @public handleNotification: Function,
            default: spyHandleNotitfication
        Test::TestMediator.initialize()
        facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_01'
        facade.registerProxy Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
        collection = facade.retrieveProxy 'TEST_COLLECTION'
        facade.registerMediator Test::TestMediator.new 'TEST_MEDIATOR', {}
        mediator = facade.retrieveMediator 'TEST_MEDIATOR'
        collection.recordHasBeenChanged { test: 'test' }, Test::TestRecord.new()
        assert.isTrue spyHandleNotitfication.called, 'Notification did not received'
        facade.remove()
        yield return
  describe '#generateId', ->
    it 'should get dummy generated ID', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
        assert.isUndefined yield collection.generateId(), 'Generated ID is defined'
        yield return
  describe '#build', ->
    it 'should create record from delegate', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
        record = collection.build test: 'test', data: 123
        assert.equal record.test, 'test', 'Record#test is incorrect'
        assert.equal record.data, 123, 'Record#data is incorrect'
        yield return
  describe '#create', ->
    it 'should create record in collection', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
        spyCollectionPush = sinon.spy collection, 'push'
        facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_FACADE_01'
        facade.registerProxy collection
        record = yield collection.create test: 'test', data: 123
        assert.isDefined record, 'Record not created'
        assert.isTrue spyCollectionPush.called, 'Record not saved'
        facade.remove()
        yield return
  describe '#update', ->
    it 'should update record in collection', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_FACADE_02'
        facade.registerProxy collection
        record = yield collection.create test: 'test', data: 123
        record.data = 456
        yield record.update()
        assert.equal (yield collection.find record.id).data, 456, 'Record not updated'
        facade.remove()
        yield return
  describe '#delete', ->
    it 'should delete record from collection', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
          @public generateId: Function,
            default: -> LeanRC::Utils.uuid.v4()
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_FACADE_03'
        facade.registerProxy collection
        record = yield collection.create test: 'test', data: 123
        yield record.delete()
        assert.isFalse yield record.isNew(), 'Record not saved'
        assert.isTrue record.isHidden, 'Record not hidden'
        facade.remove()
        yield return
  describe '#destroy', ->
    it 'should destroy record from collection', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
          @public generateId: Function,
            default: -> LeanRC::Utils.uuid.v4()
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_FACADE_04'
        facade.registerProxy collection
        record = yield collection.create test: 'test', data: 123
        yield record.destroy()
        assert.isFalse (yield collection.find record.id)?, 'Record removed'
        facade.remove()
        yield return
  describe '#find', ->
    it 'should find record from collection', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
          @public generateId: Function,
            default: -> LeanRC::Utils.uuid.v4()
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_FACADE_05'
        facade.registerProxy collection
        record = yield collection.create test: 'test', data: 123
        record2 = yield collection.find record.id
        assert.equal record.test, record2.test, 'Record not found'
        facade.remove()
        yield return
  describe '#findMany', ->
    it 'should find many records from collection', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
          @public generateId: Function,
            default: -> LeanRC::Utils.uuid.v4()
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_FACADE_06'
        facade.registerProxy collection
        { id: id1 } = yield collection.create test: 'test1'
        { id: id2 } = yield collection.create test: 'test2'
        { id: id3 } = yield collection.create test: 'test3'
        records = yield (yield collection.findMany [ id1, id2, id3 ]).toArray()
        assert.equal records.length, 3, 'Found not the three records'
        assert.equal records[0].test, 'test1', 'First record is incorrect'
        assert.equal records[1].test, 'test2', 'Second record is incorrect'
        assert.equal records[2].test, 'test3', 'Third record is incorrect'
        facade.remove()
        yield return
  describe '#clone', ->
    it 'should make record copy with new id without save', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
          @public generateId: Function,
            default: -> LeanRC::Utils.uuid.v4()
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_FACADE_09'
        facade.registerProxy collection
        original = collection.build test: 'test', data: 123
        clone = yield collection.clone original
        assert.notEqual original, clone, 'Record is not a copy but a reference'
        assert.equal original.test, clone.test, '`test` values are different'
        assert.equal original.data, clone.data, '`data` values are different'
        assert.notEqual original.id, clone.id, '`id` values are the same'
        facade.remove()
        yield return
  describe '#copy', ->
    it 'should make record copy with new id with save', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
          @public generateId: Function,
            default: -> LeanRC::Utils.uuid.v4()
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_FACADE_10'
        facade.registerProxy collection
        original = collection.build test: 'test', data: 123
        clone = yield collection.copy original
        assert.notEqual original, clone, 'Record is not a copy but a reference'
        assert.equal original.test, clone.test, '`test` values are different'
        assert.equal original.data, clone.data, '`data` values are different'
        assert.notEqual original.id, clone.id, '`id` values are the same'
        facade.remove()
        yield return
  describe '#normalize', ->
    it 'should normalize record from data', ->
      co ->
        spySerializerNormalize = sinon.spy -> co -> yield return
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
          @public generateId: Function,
            default: -> LeanRC::Utils.uuid.v4()
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
          serializer: class Serializer
            @new: (args) -> Reflect.construct @, args
            normalize: spySerializerNormalize
        facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_FACADE_11'
        facade.registerProxy collection
        record = yield collection.normalize test: 'test', data: 123
        assert.isTrue spySerializerNormalize.calledWith(Test::TestRecord, test: 'test', data: 123), 'Normalize called improperly'
        facade.remove()
        yield return
  describe '#serialize', ->
    it 'should serialize record to data', ->
      co ->
        spySerializerSerialize = sinon.spy -> co -> yield return
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
          @public generateId: Function,
            default: -> LeanRC::Utils.uuid.v4()
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
          serializer: class Serializer
            @new: (args) -> Reflect.construct @, args
            serialize: spySerializerSerialize
        facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_FACADE_12'
        facade.registerProxy collection
        record = collection.build test: 'test', data: 123
        data = yield collection.serialize record, value: 'value'
        assert.isTrue spySerializerSerialize.calledWith(record, value: 'value'), 'Serialize called improperly'
        facade.remove()
        yield return
