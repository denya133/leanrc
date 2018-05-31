{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
RecordMixin = LeanRC::RecordMixin
{ co } = LeanRC::Utils

describe 'RecordMixin', ->
  describe '.new', ->
    it 'should create item with record mixin', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) ->
              Test::TestRecord
          @attr type: String
        Test::TestRecord.initialize()
        record = Test::TestRecord.new {type: 'Test::TestRecord'}, {}
        assert.instanceOf record, Test::TestRecord, 'record is not a TestRecord instance'
      .to.not.throw Error
  describe '.parseRecordName', ->
    it 'should record name from text', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) ->
              Test::TestRecord
          @attr type: String
        Test::TestRecord.initialize()
        parsedName = Test::TestRecord.parseRecordName 'test-record'
        assert.deepEqual parsedName, ['Test', 'TestRecord'], 'Parsed incorrectly'
        parsedName = Test::TestRecord.parseRecordName 'Tester::Test'
        assert.deepEqual parsedName, ['Tester', 'TestRecord'], 'Parsed incorrectly'
      .to.not.throw Error
  describe '#parseRecordName', ->
    it 'should record name in instance from text', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) ->
              Test::TestRecord
          @attr type: String
        Test::TestRecord.initialize()
        vsRecord = Test::TestRecord.new()
        parsedName = vsRecord.parseRecordName 'test-record'
        assert.deepEqual parsedName, ['Test', 'TestRecord'], 'Parsed incorrectly'
        parsedName = vsRecord.parseRecordName 'Tester::Test'
        assert.deepEqual parsedName, ['Tester', 'TestRecord'], 'Parsed incorrectly'
      .to.not.throw Error
  describe '.parentClassNames', ->
    it 'should get records class parent class names', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) ->
              Test::TestRecord
          @attr type: String
        Test::TestRecord.initialize()
        classNames = Test::TestRecord.parentClassNames()
        assert.deepEqual classNames, [ 'CoreObject', 'RecordMixin', 'TestRecord' ], 'Parsed incorrectly'
      .to.not.throw Error
  describe '.attribute, .attr', ->
    it 'should define attributes for class', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr type: String
          @attribute string: String
          @attr number: Number
          @attribute boolean: Boolean,
            through: 'Test'
          @attr date: Date
        Test::TestRecord.initialize()
        assert.isTrue 'string' of Test::TestRecord.attributes, 'Attribute `string` did not defined'
        assert.isTrue 'number' of Test::TestRecord.attributes, 'Attribute `number` did not defined'
        assert.isTrue 'boolean' of Test::TestRecord.attributes, 'Attribute `boolean` did not defined'
        assert.isTrue 'date' of Test::TestRecord.attributes, 'Attribute `date` did not defined'
        assert.equal Test::TestRecord.edges.boolean.through, 'Test', 'Edge through `Test` did not defined'
      .to.not.throw Error
  describe '.computed, .comp', ->
    it 'should define computed properties for class', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr type: String
          @computed string: String,
            get: (aoData) -> aoData
          @comp number: Number,
            get: (aoData) -> aoData
          @computed boolean: Boolean,
            get: (aoData) -> aoData
          @comp date: Date,
            get: (aoData) -> aoData
        Test::TestRecord.initialize()
        assert.isTrue 'string' of Test::TestRecord.computeds, 'Computed property `string` did not defined'
        assert.isTrue 'number' of Test::TestRecord.computeds, 'Computed property `number` did not defined'
        assert.isTrue 'boolean' of Test::TestRecord.computeds, 'Computed property `boolean` did not defined'
        assert.isTrue 'date' of Test::TestRecord.computeds, 'Computed property `date` did not defined'
      .to.not.throw Error
  describe '#create, #isNew', ->
    it 'should create new record', ->
      co ->
        KEY = 'TEST_RECORD_01'

        class TestsModule extends LeanRC
          @inheritProtected()
        TestsModule.initialize()

        class TestsCollection extends TestsModule::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module TestsModule
        TestsCollection.initialize()
        class TestRecord extends TestsModule::CoreObject
          @inheritProtected()
          @include TestsModule::RecordMixin
          @module TestsModule
          @public @static findRecordByName: Function,
            default: (asType) -> TestsModule::TestRecord
          @attr type: String
        TestRecord.initialize()
        collection = TestsModule::TestsCollection.new KEY,
          delegate: TestsModule::TestRecord
        collection.onRegister()
        record = TestsModule::TestRecord.new
          id: yield collection.generateId()
          type: 'Test::TestRecord'
        , collection
        assert.isTrue yield record.isNew(), 'Record is not new'
        yield record.create()
        assert.isFalse yield record.isNew(), 'Record is still new'
        yield return
  describe '#destroy', ->
    it 'should remove record', ->
      co ->
        KEY = 'TEST_RECORD_02'
        class TestsModule extends LeanRC
          @inheritProtected()
        TestsModule.initialize()

        class TestsCollection extends TestsModule::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module TestsModule
        TestsCollection.initialize()
        class TestRecord extends TestsModule::CoreObject
          @inheritProtected()
          @include TestsModule::RecordMixin
          @module TestsModule
          @public @static findRecordByName: Function,
            default: (asType) -> TestsModule::TestRecord
          @attr type: String
        TestRecord.initialize()
        collection = TestsModule::TestsCollection.new KEY,
          delegate: TestsModule::TestRecord
        collection.onRegister()
        record = TestsModule::TestRecord.new
          id: yield collection.generateId()
          type: 'Test::TestRecord'
        , collection
        assert.isTrue (yield record.isNew()), 'Record is not new'
        yield record.create()
        assert.isFalse (yield record.isNew()), 'Record is still new'
        yield record.destroy()
        assert.isFalse (yield collection.find(record.id))?, 'Record still in collection'
        yield return
  describe '#update', ->
    it 'should update record', ->
      co ->
        KEY = 'TEST_RECORD_03'
        class TestsModule extends LeanRC
          @inheritProtected()
        TestsModule.initialize()

        class TestsCollection extends TestsModule::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module TestsModule
        TestsCollection.initialize()
        class TestRecord extends TestsModule::CoreObject
          @inheritProtected()
          @include TestsModule::RecordMixin
          @module TestsModule
          @public @static findRecordByName: Function,
            default: (asType) -> TestsModule::TestRecord
          @attr type: String
          @attr test: String
        TestRecord.initialize()
        collection = TestsModule::TestsCollection.new KEY,
          delegate: TestsModule::TestRecord
        collection.onRegister()
        record = TestsModule::TestRecord.new
          id: yield collection.generateId()
          type: 'Test::TestRecord'
          test: 'test1'
        , collection
        yield record.create()
        assert.equal (yield collection.find record.id).test, 'test1', 'Initial attr not saved'
        record.test = 'test2'
        yield record.update()
        assert.equal (yield collection.find record.id).test, 'test2', 'Updated attr not saved'
        yield return
  describe '#clone', ->
    it 'should clone record', ->
      co ->
        KEY = 'TEST_RECORD_04'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class TestCollection extends Test::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        TestCollection.initialize()
        class TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr type: String
          @attr test: String
        TestRecord.initialize()
        collection = TestCollection.new KEY,
          delegate: Test::TestRecord
        collection.onRegister()
        record = TestRecord.new
          id: yield collection.generateId()
          type: 'Test::TestRecord'
          test: 'test1'
        , collection
        recordCopy = yield record.clone()
        assert.equal record.test, recordCopy.test
        assert.notEqual record.id, recordCopy.id
  describe '#save', ->
    it 'should save record', ->
      co ->
        KEY = 'TEST_RECORD_05'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class TestCollection extends Test::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        TestCollection.initialize()
        class TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr id: String
          @attr type: String
          @attr isHidden: Boolean, { default: no }
          @attr test: String
        TestRecord.initialize()
        collection = TestCollection.new KEY, delegate: Test::TestRecord
        collection.onRegister()
        record = TestRecord.new
          id: yield collection.generateId()
          type: 'Test::TestRecord'
          test: 'test1'
        , collection
        yield record.save()
        assert.isTrue (yield collection.find(record.id))?, 'Record is not saved'
        yield return
  describe '#delete', ->
    it 'should create and then delete a record', ->
      co ->
        KEY = 'TEST_RECORD_06'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class TestCollection extends Test::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        TestCollection.initialize()
        class TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr id: String
          @attr type: String
          @attr isHidden: Boolean, { default: no }
          @attr test: String
        TestRecord.initialize()
        collection = TestCollection.new KEY, delegate: Test::TestRecord
        collection.onRegister()
        record = TestRecord.new
          id: yield collection.generateId()
          type: 'Test::TestRecord'
          test: 'test1'
        , collection
        yield record.save()
        assert.isTrue (yield collection.find(record.id))?, 'Record is not saved'
        yield record.delete()
        assert.isTrue (yield collection.find record.id).isHidden, 'Record is not marked as delete'
        yield return
  describe '#copy', ->
    it 'should create and then copy the record', ->
      co ->
        KEY = 'TEST_RECORD_07'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class TestCollection extends Test::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        TestCollection.initialize()
        class TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr type: String
          @attr test: String
        TestRecord.initialize()
        collection = TestCollection.new KEY, delegate: Test::TestRecord
        collection.onRegister()
        record = TestRecord.new
          id: yield collection.generateId()
          type: 'Test::TestRecord'
          test: 'test1'
        , collection
        yield record.save()
        assert.isTrue (yield collection.find(record.id))?, 'Record is not saved'
        newRecord = yield record.copy()
        assert.isTrue (yield collection.find(newRecord.id))?, 'Record copy not saved'
        yield return
  describe '#decrement, #increment, #toggle', ->
    it 'should decrease/increase value of number attribute and toggle boolean', ->
      co ->
        KEY = 'TEST_RECORD_08'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class TestCollection extends Test::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        TestCollection.initialize()
        class Test::TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr type: String
          @attr test: Number
          @attr has: Boolean
        Test::TestRecord.initialize()
        collection = TestCollection.new KEY, delegate: Test::TestRecord
        collection.onRegister()
        record = Test::TestRecord.new
          id: yield collection.generateId()
          type: 'Test::TestRecord'
          test: 1000
          has: true
        , collection
        yield record.save()
        assert.equal record.test, 1000, 'Initial number value is incorrect'
        assert.isTrue record.has, 'Initial boolean value is incorrect'
        record.decrement 'test', 7
        assert.equal record.test, 993, 'Descreased number value is incorrect'
        record.increment 'test', 19
        assert.equal record.test, 1012, 'Increased number value is incorrect'
        record.toggle 'has'
        assert.isFalse record.has, 'Toggled boolean value is incorrect'
        record.toggle 'has'
        assert.isTrue record.has, 'Toggled boolean value is incorrect'
        yield return
  describe '#updateAttribute, #updateAttributes', ->
    it 'should update attributes', ->
      co ->
        KEY = 'TEST_RECORD_09'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class TestCollection extends Test::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        TestCollection.initialize()
        class Test::TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr type: String
          @attr test: Number
          @attr has: Boolean
          @attr word: String
        Test::TestRecord.initialize()
        collection = TestCollection.new KEY, delegate: Test::TestRecord
        collection.onRegister()
        record = Test::TestRecord.new
          id: yield collection.generateId()
          type: 'Test::TestRecord'
          test: 1000
          has: true
          word: 'test'
        , collection
        record.save()
        assert.equal record.test, 1000, 'Initial number value is incorrect'
        assert.isTrue record.has, 'Initial boolean value is incorrect'
        record.updateAttribute 'test', 200
        assert.equal record.test, 200, 'Number attribue not updated correctly'
        record.updateAttribute 'word', 'word'
        assert.equal record.word, 'word', 'String attribue not updated correctly'
        record.updateAttribute 'has', no
        assert.equal record.has, no, 'Boolean attribue not updated correctly'
        record.updateAttributes test: 888, has: yes, word: 'other'
        assert.equal record.test, 888, 'Number attribue not updated correctly'
        assert.equal record.has, yes, 'Boolean attribue not updated correctly'
        assert.equal record.word, 'other', 'String attribue not updated correctly'
        yield return
  describe '#touch', ->
    it 'should save data with date', ->
      co ->
        KEY = 'TEST_RECORD_10'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class TestCollection extends Test::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        TestCollection.initialize()
        class Test::BasicTestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::BasicTestRecord
          @attr type: String
          @attribute updatedAt: Date
          @attribute test: Number
          @attribute has: Boolean
          @attribute word: String
        Test::BasicTestRecord.initialize()
        class Test::TestRecord extends Test::BasicTestRecord
          @inheritProtected()
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
        Test::TestRecord.initialize()
        collection = TestCollection.new KEY, delegate: Test::TestRecord
        collection.onRegister()
        record = Test::TestRecord.new
          id: yield collection.generateId()
          type: 'Test::TestRecord'
          test: 1000
          has: true
          word: 'test'
        , collection
        yield record.touch()
        assert.equal (yield collection.find record.id).test, 1000, 'Number attribue not updated correctly'
        assert.equal (yield collection.find record.id).has, yes, 'Boolean attribue not updated correctly'
        assert.equal (yield collection.find record.id).word, 'test', 'String attribue not updated correctly'
        assert.isAtMost (yield collection.find record.id).updatedAt, new Date(), 'Date attribue not updated correctly'
        yield return
  describe '#changedAttributes, #resetAttribute, #rollbackAttributes', ->
    it 'should test, reset and rollback attributes', ->
      co ->
        KEY = 'TEST_RECORD_11'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class TestCollection extends Test::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        TestCollection.initialize()
        class Test::TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr type: String
          @attr test: Number
          @attr has: Boolean
          @attr word: String
        Test::TestRecord.initialize()
        collection = TestCollection.new KEY, delegate: Test::TestRecord
        collection.onRegister()
        record = Test::TestRecord.new
          type: 'Test::TestRecord'
          test: 1000
          has: true
          word: 'test'
          id: yield collection.generateId()
        , collection
        yield record.save()
        record.test = 888
        assert.deepEqual record.changedAttributes().test, [ 1000, 888 ], 'Update is incorrect'
        record.resetAttribute 'test'
        assert.isUndefined record.changedAttributes().test, 'Reset is incorrect'
        record.test = 888
        record.has = no
        record.word = 'other'
        record.rollbackAttributes()
        assert.equal record.test, 1000, 'Number attribue did not rolled back correctly'
        assert.equal record.has, yes, 'Boolean attribue did not rolled back correctly'
        assert.equal record.word, 'test', 'String attribue did not rolled back correctly'
        yield return
  describe '.normalize, .serialize', ->
    it 'should serialize and deserialize attributes', ->
      co ->
        KEY = 'TEST_RECORD_12'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr type: String
          @attr test: Number
          @attr has: Boolean
          @attr word: String
        Test::TestRecord.initialize()
        record = yield Test::TestRecord.normalize
          type: 'Test::TestRecord'
          test: 1000
          has: true
          word: 'test'
        , {}
        assert.propertyVal record, 'test', 1000, 'Property `test` not defined'
        assert.propertyVal record, 'has', yes, 'Property `has` not defined'
        assert.propertyVal record, 'word', 'test', 'Property `word` not defined'
        assert.deepEqual record.changedAttributes(), {}, 'Attributes are altered'
        snapshot = yield Test::TestRecord.serialize record
        assert.deepEqual snapshot, { type: 'Test::TestRecord', test: 1000, has: true, word: 'test' }, 'Snapshot is incorrect'
        yield return
  describe '.normalize, .serialize', ->
    it 'should serialize and deserialize attributes', ->
      co ->
        KEY = 'TEST_RECORD_12'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr type: String
          @attr test: Number
          @attr has: Boolean
          @attr word: String
        Test::TestRecord.initialize()
        record = yield Test::TestRecord.normalize
          type: 'Test::TestRecord'
          test: 1000
          has: true
          word: 'test'
        , {}
        assert.propertyVal record, 'test', 1000, 'Property `test` not defined'
        assert.propertyVal record, 'has', yes, 'Property `has` not defined'
        assert.propertyVal record, 'word', 'test', 'Property `word` not defined'
        assert.deepEqual record.changedAttributes(), {}, 'Attributes are altered'
        snapshot = yield Test::TestRecord.serialize record
        assert.deepEqual snapshot, { type: 'Test::TestRecord', test: 1000, has: true, word: 'test' }, 'Snapshot is incorrect'
        yield return
  describe '.objectize', ->
    it 'should objectize attributes', ->
      co ->
        KEY = 'TEST_RECORD_12'
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr type: String
          @attr test: Number
          @attr has: Boolean
          @attr word: String
        Test::TestRecord.initialize()
        record = yield Test::TestRecord.normalize
          type: 'Test::TestRecord'
          test: 1000
          has: true
          word: 'test'
        , {}
        assert.propertyVal record, 'test', 1000, 'Property `test` not defined'
        assert.propertyVal record, 'has', yes, 'Property `has` not defined'
        assert.propertyVal record, 'word', 'test', 'Property `word` not defined'
        assert.deepEqual record.changedAttributes(), {}, 'Attributes are altered'
        snapshot = Test::TestRecord.objectize record
        assert.deepEqual snapshot, { type: 'Test::TestRecord', test: 1000, has: true, word: 'test' }, 'JSON snapshot is incorrect'
        yield return
  describe '.replicateObject', ->
    facade = null
    KEY = 'TEST_RECORD_12'
    after -> facade?.remove?()
    it 'should create replica for record', ->
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
        class TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @include LeanRC::ChainsMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr id: String
          @attr type: String
          @attr test: Number
          @attr has: Boolean
          @attr word: String
          @chains [ 'create' ]
          @beforeHook 'beforeCreate', only: [ 'create' ]
          @public beforeCreate: Function,
            default: (args...) ->
              @id ?= @collection.generateId()
              args
        TestRecord.initialize()
        COLLECTION = 'COLLECTION'
        collection = facade.registerProxy MyCollection.new COLLECTION,
          delegate: Test::TestRecord
          serializer: Test::Serializer
        collection = facade.retrieveProxy COLLECTION
        record = yield collection.create
          type: 'Test::TestRecord'
          test: 1000
          has: true
          word: 'test'
        replica = yield TestRecord.replicateObject record
        assert.deepEqual replica,
          attributes: {}
          type: 'instance'
          class: 'TestRecord'
          multitonKey: KEY
          collectionName: COLLECTION
          isNew: no
          id: record.id
        record = collection.build
          type: 'Test::TestRecord'
          test: 1000
          has: true
          word: 'test'
        replica = yield TestRecord.replicateObject record
        assert.deepEqual replica,
          type: 'instance'
          class: 'TestRecord'
          multitonKey: KEY
          collectionName: COLLECTION
          isNew: yes
          attributes: id: null, type: 'Test::TestRecord', test: 1000, has: yes, word: 'test'
        facade.remove()
        yield return
  describe '.restoreObject', ->
    facade = null
    KEY = 'TEST_RECORD_13'
    after -> facade?.remove?()
    it 'should restore record from replica', ->
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
        class TestRecord extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @include LeanRC::ChainsMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attr id: String
          @attr type: String
          @attr test: Number
          @attr has: Boolean
          @attr word: String
          @chains [ 'create' ]
          @beforeHook 'beforeCreate', only: [ 'create' ]
          @public @async beforeCreate: Function,
            default: (args...) ->
              @id ?= yield @collection.generateId()
              args
        TestRecord.initialize()
        COLLECTION = 'COLLECTION'
        collection = facade.registerProxy MyCollection.new COLLECTION,
          delegate: Test::TestRecord
          serializer: Test::Serializer
        collection = facade.retrieveProxy COLLECTION
        record = yield collection.create
          type: 'Test::TestRecord'
          test: 1000
          has: true
          word: 'test'
        restoredRecord = yield TestRecord.restoreObject Test,
          type: 'instance'
          class: 'TestRecord'
          multitonKey: KEY
          collectionName: COLLECTION
          isNew: no
          id: record.id
        assert.notEqual record, restoredRecord
        assert.deepEqual record, restoredRecord
        record = collection.build
          id: '123'
          type: 'Test::TestRecord'
          test: 1000
          has: true
          word: 'test'
        restoredRecord = yield TestRecord.restoreObject Test,
          type: 'instance'
          class: 'TestRecord'
          multitonKey: KEY
          collectionName: COLLECTION
          isNew: yes
          attributes: id: '123', type: 'Test::TestRecord', test: 1000, has: yes, word: 'test'
        assert.notEqual record, restoredRecord
        assert.deepEqual record, restoredRecord
        facade.remove()
        yield return
