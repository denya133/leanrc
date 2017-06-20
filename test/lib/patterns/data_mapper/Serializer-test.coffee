{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Serializer = LeanRC::Serializer
Record = LeanRC::Record
{ co } = LeanRC::Utils

describe 'Serializer', ->
  describe '#normalize', ->
    it "should normalize object value", ->
      expect ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attribute string: String
          @attribute number: Number
          @attribute boolean: Boolean
        Test::TestRecord.initialize()
        serializer = Serializer.new()
        record = serializer.normalize Test::TestRecord,
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        assert.instanceOf record, Test::TestRecord, 'Normalize is incorrect'
        assert.equal record.type, 'Test::TestRecord', '`type` is incorrect'
        assert.equal record.string, 'string', '`string` is incorrect'
        assert.equal record.number, 123, '`number` is incorrect'
        assert.equal record.boolean, yes, '`boolean` is incorrect'
      .to.not.throw Error
  describe '#serialize', ->
    it "should serialize Record.prototype value", ->
      expect ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attribute string: String
          @attribute number: Number
          @attribute boolean: Boolean
        Test::TestRecord.initialize()
        serializer = Serializer.new()
        data = serializer.serialize Test::TestRecord.new
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        assert.instanceOf data, Object, 'Serialize is incorrect'
        assert.equal data.type, 'Test::TestRecord', '`type` is incorrect'
        assert.equal data.string, 'string', '`string` is incorrect'
        assert.equal data.number, 123, '`number` is incorrect'
        assert.equal data.boolean, yes, '`boolean` is incorrect'
      .to.not.throw Error
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
