{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Objectizer = LeanRC::Objectizer
Record = LeanRC::Record
{ co } = LeanRC::Utils

describe 'Objectizer', ->
  describe '#recoverize', ->
    it "should recoverize object value", ->
      co ->
      # expect ->
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
        objectizer = Objectizer.new()
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
      # .to.not.throw Error
  describe '#objectize', ->
    it "should objectize Record.prototype value", ->
      co ->
      # expect ->
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
        objectizer = Objectizer.new()
        data = yield objectizer.objectize Test::TestRecord.new
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        assert.instanceOf data, Object, 'Objectize is incorrect'
        assert.equal data.type, 'Test::TestRecord', '`type` is incorrect'
        assert.equal data.string, 'string', '`string` is incorrect'
        assert.equal data.number, 123, '`number` is incorrect'
        assert.equal data.boolean, yes, '`boolean` is incorrect'
        yield return
      # .to.not.throw Error
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
