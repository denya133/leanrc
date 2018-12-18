{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{
  FuncG, SubsetG
  RecordInterface
  Objectizer
  Record
  Utils: { co }
} = LeanRC::

describe 'Objectizer', ->
  describe '#recoverize', ->
    it "should recoverize object value", ->
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
        objectizer = Objectizer.new TestsCollection.new('Tests', delegate: 'TestRecord')
        record = yield objectizer.recoverize Test::TestRecord,
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        assert.instanceOf record, Test::TestRecord, 'Recoverize is incorrect'
        assert.equal record.type, 'Test::TestRecord', '`type` is incorrect'
        assert.equal record.string, 'string', '`string` is incorrect'
        assert.equal record.number, 123, '`number` is incorrect'
        assert.equal record.boolean, yes, '`boolean` is incorrect'
        yield return
  describe '#objectize', ->
    it "should objectize Record.prototype value", ->
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
        objectizer = Objectizer.new col
        data = yield objectizer.objectize(Test::TestRecord.new({
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        }, col))
        assert.instanceOf data, Object, 'Objectize is incorrect'
        assert.equal data.type, 'Test::TestRecord', '`type` is incorrect'
        assert.equal data.string, 'string', '`string` is incorrect'
        assert.equal data.number, 123, '`number` is incorrect'
        assert.equal data.boolean, yes, '`boolean` is incorrect'
        yield return
  describe '.replicateObject', ->
    facade = null
    KEY = 'TEST_SERIALIZER_001'
    after -> facade?.remove?()
    it 'should create replica for objectizer', ->
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
        class MyObjectizer extends LeanRC::Objectizer
          @inheritProtected()
          @module Test
        MyObjectizer.initialize()
        COLLECTION = 'COLLECTION'
        collection = facade.registerProxy MyCollection.new COLLECTION,
          delegate: Test::Record
          objectizer: MyObjectizer
        collection = facade.retrieveProxy COLLECTION
        replica = yield MyObjectizer.replicateObject collection.objectizer
        assert.deepEqual replica,
          type: 'instance'
          class: 'MyObjectizer'
          multitonKey: KEY
          collectionName: COLLECTION
        yield return
  describe '.restoreObject', ->
    facade = null
    KEY = 'TEST_SERIALIZER_002'
    after -> facade?.remove?()
    it 'should restore objectizer from replica', ->
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
        class MyObjectizer extends LeanRC::Objectizer
          @inheritProtected()
          @module Test
        MyObjectizer.initialize()
        COLLECTION = 'COLLECTION'
        collection = facade.registerProxy MyCollection.new COLLECTION,
          delegate: Test::Record
          objectizer: MyObjectizer
        collection = facade.retrieveProxy COLLECTION
        restoredRecord = yield MyObjectizer.restoreObject Test,
          type: 'instance'
          class: 'MyObjectizer'
          multitonKey: KEY
          collectionName: COLLECTION
        assert.deepEqual collection.objectizer, restoredRecord
        yield return
