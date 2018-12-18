{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{
  FuncG, SubsetG
  RecordInterface
  Serializer
  Record
  Utils: { co }
} = LeanRC::

describe 'Serializer', ->
  describe '#normalize', ->
    it "should normalize object value", ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> Test::TestRecord
          @attribute string: String
          @attribute number: Number
          @attribute boolean: Boolean
          @initialize()
        serializer = Serializer.new TestsCollection.new('Tests', delegate: 'TestRecord')
        record = yield serializer.normalize Test::TestRecord,
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        assert.instanceOf record, Test::TestRecord, 'Normalize is incorrect'
        assert.equal record.type, 'Test::TestRecord', '`type` is incorrect'
        assert.equal record.string, 'string', '`string` is incorrect'
        assert.equal record.number, 123, '`number` is incorrect'
        assert.equal record.boolean, yes, '`boolean` is incorrect'
        yield return
  describe '#serialize', ->
    it "should serialize Record.prototype value", ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> Test::TestRecord
          @attribute string: String
          @attribute number: Number
          @attribute boolean: Boolean
          @initialize()
        col = TestsCollection.new('Tests', delegate: 'TestRecord')
        serializer = Serializer.new col
        data = yield serializer.serialize Test::TestRecord.new({
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        }, col)
        assert.instanceOf data, Object, 'Serialize is incorrect'
        assert.equal data.type, 'Test::TestRecord', '`type` is incorrect'
        assert.equal data.string, 'string', '`string` is incorrect'
        assert.equal data.number, 123, '`number` is incorrect'
        assert.equal data.boolean, yes, '`boolean` is incorrect'
        yield return
  describe '.replicateObject', ->
    facade = null
    KEY = 'TEST_SERIALIZER_001'
    after -> facade?.remove?()
    it 'should create replica for serializer', ->
      co ->
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class MyCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        MyCollection.initialize()
        class MySerializer extends LeanRC::Serializer
          @inheritProtected()
          @module Test
        MySerializer.initialize()
        COLLECTION = 'COLLECTION'
        collection = facade.registerProxy MyCollection.new COLLECTION,
          delegate: Test::Record
          serializer: MySerializer
        collection = facade.retrieveProxy COLLECTION
        replica = yield MySerializer.replicateObject collection.serializer
        assert.deepEqual replica,
          type: 'instance'
          class: 'MySerializer'
          multitonKey: KEY
          collectionName: COLLECTION
        yield return
  describe '.restoreObject', ->
    facade = null
    KEY = 'TEST_SERIALIZER_002'
    after -> facade?.remove?()
    it 'should restore serializer from replica', ->
      co ->
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class MyCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        MyCollection.initialize()
        class MySerializer extends LeanRC::Serializer
          @inheritProtected()
          @module Test
        MySerializer.initialize()
        COLLECTION = 'COLLECTION'
        collection = facade.registerProxy MyCollection.new COLLECTION,
          delegate: Test::Record
          serializer: MySerializer
        collection = facade.retrieveProxy COLLECTION
        restoredRecord = yield MySerializer.restoreObject Test,
          type: 'instance'
          class: 'MySerializer'
          multitonKey: KEY
          collectionName: COLLECTION
        assert.deepEqual collection.serializer, restoredRecord
        yield return
