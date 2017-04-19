{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
RC = require 'RC'
LeanRC = require.main.require 'lib'
RecordMixin = LeanRC::RecordMixin
{ co } = RC::Utils

describe 'RecordMixin', ->
  describe '.new', ->
    it 'should create item with record mixin', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) ->
              Test::TestRecord
        Test::TestRecord.initialize()
        record = Test::TestRecord.new {}, {}
        assert.instanceOf record, Test::TestRecord, 'record is not a TestRecord instance'
      .to.not.throw Error
  describe '.parseRecordName', ->
    it 'should record name from text', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) ->
              Test::TestRecord
        Test::TestRecord.initialize()
        parsedName = Test::TestRecord.parseRecordName 'test-record'
        assert.deepEqual parsedName, ['Test', 'TestRecord'], 'Parsed incorrectly'
        parsedName = Test::TestRecord.parseRecordName 'Tester::Test'
        assert.deepEqual parsedName, ['Tester', 'Test'], 'Parsed incorrectly'
      .to.not.throw Error
  describe '#parseRecordName', ->
    it 'should record name in instance from text', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) ->
              Test::TestRecord
        Test::TestRecord.initialize()
        vsRecord = Test::TestRecord.new()
        parsedName = vsRecord.parseRecordName 'test-record'
        assert.deepEqual parsedName, ['Test', 'TestRecord'], 'Parsed incorrectly'
        parsedName = vsRecord.parseRecordName 'Tester::Test'
        assert.deepEqual parsedName, ['Tester', 'Test'], 'Parsed incorrectly'
      .to.not.throw Error
  describe '.parentClassNames', ->
    it 'should get records class parent class names', ->
      expect ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) ->
              Test::TestRecord
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

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
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

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
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

        class TestsCollection extends TestsModule::CoreObject
          @inheritProtected()
          @include TestsModule::CollectionInterface
          @Module: TestsModule
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: TestsModule::Facade,
            get: -> TestsModule::Facade.getInstance KEY
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              if (yield @find item.id)?
                throw new Error "Item '#{item.id}' is already exists"
              item.id ?= TestsModule::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public find: Function,
            default: (id) -> TestsModule::Promise.resolve @[iphData][id]
          @public dfsgdsfgdsfgdfsg: Function,
            default: (asKey, asName) ->
          @public init: Function,
            default: (asKey, asName) ->
              @super asKey, asName
              @[ipsKey] = asKey; @[ipsName] = asName; @[iphData] = {}
              return
        TestsCollection.initialize()
        class TestRecord extends TestsModule::CoreObject
          @inheritProtected()
          @include TestsModule::RecordMixin
          @Module: TestsModule
          @public @static findModelByName: Function,
            default: (asType) -> TestsModule::TestRecord
        TestRecord.initialize()
        collection = TestsModule::TestsCollection.new KEY
        record = TestsModule::TestRecord.new {}, collection
        assert.isTrue yield record.isNew(), 'Record is not new'
        yield record.create()
        assert.isFalse yield record.isNew(), 'Record is still new'
        try yield record.create() catch err
        assert.instanceOf err, Error, 'Record not created'
        yield return
  describe '#destroy', ->
    it 'should remove record', ->
      co ->
        KEY = 'TEST_RECORD_02'
        class TestsModule extends LeanRC
          @inheritProtected()
        TestsModule.initialize()

        class TestsCollection extends TestsModule::CoreObject
          @inheritProtected()
          @include TestsModule::CollectionInterface
          @Module: TestsModule
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: TestsModule::Facade,
            get: -> TestsModule::Facade.getInstance KEY
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              if (yield @find item.id)?
                throw new Error "Item '#{item.id}' is already exists"
              item.id ?= TestsModule::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public remove: Function,
            default: (id) ->
              TestsModule::Promise.resolve Reflect.deleteProperty @[iphData], id
          @public find: Function,
            default: (id) -> TestsModule::Promise.resolve @[iphData][id]
          @public init: Function,
            default: (asKey, asName) ->
              @super asKey, asName
              @[ipsKey] = asKey; @[ipsName] = asName; @[iphData] = {}
              return
        TestsCollection.initialize()
        class TestRecord extends TestsModule::CoreObject
          @inheritProtected()
          @include TestsModule::RecordMixin
          @Module: TestsModule
          @public @static findModelByName: Function,
            default: (asType) -> TestsModule::TestRecord
        TestRecord.initialize()
        collection = TestsModule::TestsCollection.new KEY
        record = TestsModule::TestRecord.new {}, collection
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

        class TestsCollection extends TestsModule::CoreObject
          @inheritProtected()
          @include TestsModule::CollectionInterface
          @Module: TestsModule
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: TestsModule::Facade,
            get: -> TestsModule::Facade.getInstance KEY
          @public find: Function,
            default: (id) -> TestsModule::Promise.resolve @[iphData][id]
          @public clone: Function,
            default: (item) ->
              result = item.constructor.new item, @
              result[key] = item[key]  for key of item.constructor.attributes
              result.id = TestsModule::Utils.uuid.v4()
              result
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              if (yield @find item.id)?
                throw new Error "Item '#{item.id}' is already exists"
              item.id ?= TestsModule::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              if (yield @find id)?
                @[iphData][item.id] = @clone item
              else
                throw new Error "Item '#{id}' is missing"
              @[iphData][item.id]?
          constructor: (asKey, asName) ->
            super asKey, asName
            @[ipsKey] = asKey; @[ipsName] = asName; @[iphData] = {}
        TestsCollection.initialize()
        class TestRecord extends TestsModule::CoreObject
          @inheritProtected()
          @include TestsModule::RecordMixin
          @Module: TestsModule
          @public @static findModelByName: Function,
            default: (asType) -> TestsModule::TestRecord
          @attr test: String
        TestRecord.initialize()
        collection = TestsModule::TestsCollection.new KEY
        record = TestsModule::TestRecord.new { test: 'test1' }, collection
        yield record.create()
        assert.equal (yield collection.find record.id).test, 'test1', 'Initial attr not saved'
        record.test = 'test2'
        yield record.update()
        assert.equal (yield collection.find record.id).test, 'test2', 'Updated attr not saved'
        yield return
  describe '#clone', ->
    it 'should clone record', ->
      expect ->
        KEY = 'TEST_RECORD_04'
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::Collection extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::CollectionInterface
          @Module: Test
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: LeanRC::Facade,
            get: -> LeanRC::Facade.getInstance KEY
          @public find: Function,
            default: (id) -> RC::Promise.resolve @[iphData][id]
          @public clone: Function,
            default: (item) ->
              result = item.constructor.new item, @
              result[key] = item[key]  for key of item.constructor.attributes
              result.id = RC::Utils.uuid.v4()
              result
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              if (yield @find item.id)?
                throw new Error "Item '#{item.id}' is already exists"
              item.id ?= RC::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          constructor: (asKey, asName) ->
            super asKey, asName
            @[ipsKey] = asKey; @[ipsName] = asName; @[iphData] = {}
        Test::Collection.initialize()
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @attr test: String
        Test::TestRecord.initialize()
        collection = Test::Collection.new KEY
        record = Test::TestRecord.new { test: 'test1' }, collection
        recordCopy = record.clone()
        assert.equal record.test, recordCopy.test
        assert.notEqual record.id, recordCopy.id
      .to.not.throw Error
  describe '#save', ->
    it 'should save record', ->
      co ->
        KEY = 'TEST_RECORD_05'
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::Collection extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::CollectionInterface
          @Module: Test
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: LeanRC::Facade,
            get: -> LeanRC::Facade.getInstance KEY
          @public find: Function,
            default: (id) -> RC::Promise.resolve @[iphData][id]
          @public clone: Function,
            default: (item) ->
              result = item.constructor.new item, @
              result[key] = item[key]  for key of item.constructor.attributes
              result.id = RC::Utils.uuid.v4()
              result
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              if (yield @find item.id)?
                throw new Error "Item '#{item.id}' is already exists"
              item.id ?= RC::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          constructor: (asKey, asName) ->
            super asKey, asName
            @[ipsKey] = asKey; @[ipsName] = asName; @[iphData] = {}
        Test::Collection.initialize()
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @attr test: String
        Test::TestRecord.initialize()
        collection = Test::Collection.new KEY
        record = Test::TestRecord.new { test: 'test1' }, collection
        yield record.save()
        assert.isTrue (yield collection.find(record.id))?, 'Record is not saved'
        yield return
  describe '#delete', ->
    it 'should create and then delete a record', ->
      co ->
        KEY = 'TEST_RECORD_06'
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::Collection extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::CollectionInterface
          @Module: Test
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: LeanRC::Facade,
            get: -> LeanRC::Facade.getInstance KEY
          @public find: Function,
            default: (id) ->
              RC::Promise.resolve unless @[iphData][id]?.isHidden then @[iphData][id]
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              if (yield @find item.id)?
                throw new Error "Item '#{item.id}' is already exists"
              item.id ?= RC::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          constructor: (asKey, asName) ->
            super asKey, asName
            @[ipsKey] = asKey; @[ipsName] = asName; @[iphData] = {}
        Test::Collection.initialize()
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @attr test: String
        Test::TestRecord.initialize()
        collection = Test::Collection.new KEY
        record = Test::TestRecord.new { test: 'test1' }, collection
        yield record.save()
        assert.isTrue (yield collection.find(record.id))?, 'Record is not saved'
        yield record.delete()
        assert.isFalse (yield collection.find(record.id))?, 'Record is not marked as delete'
        yield return
  describe '#copy', ->
    it 'should create and then copy the record', ->
      co ->
        KEY = 'TEST_RECORD_07'
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::Collection extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::CollectionInterface
          @Module: Test
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: LeanRC::Facade,
            get: -> LeanRC::Facade.getInstance KEY
          @public find: Function,
            default: (id) -> RC::Promise.resolve @[iphData][id]
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              if (yield @find item.id)?
                throw new Error "Item '#{item.id}' is already exists"
              item.id ?= RC::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public clone: Function,
            default: (item) ->
              result = item.constructor.new item, @
              result[key] = item[key]  for key of item.constructor.attributes
              result.id = RC::Utils.uuid.v4()
              result
          @public copy: Function,
            default: (item) ->
              newItem = @clone item
              yield newItem.save()
              newItem
          constructor: (asKey, asName) ->
            super asKey, asName
            @[ipsKey] = asKey; @[ipsName] = asName; @[iphData] = {}
        Test::Collection.initialize()
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @attr test: String
        Test::TestRecord.initialize()
        collection = Test::Collection.new KEY
        record = Test::TestRecord.new { test: 'test1' }, collection
        yield record.save()
        assert.isTrue (yield collection.find(record.id))?, 'Record is not saved'
        newRecord = yield record.copy()
        assert.isTrue (yield collection.find(newRecord.id))?, 'Record copy not saved'
        yield return
  describe '#decrement, #increment, #toggle', ->
    it 'should decrease/increase value of number attribute and toggle boolean', ->
      co ->
        KEY = 'TEST_RECORD_08'
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::Collection extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::CollectionInterface
          @Module: Test
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: LeanRC::Facade,
            get: -> LeanRC::Facade.getInstance KEY
          @public find: Function,
            default: (id) -> RC::Promise.resolve @[iphData][id]
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              if (yield @find item.id)?
                throw new Error "Item '#{item.id}' is already exists"
              item.id ?= RC::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              throw new Error "Item '#{id}' is missing"  unless (yield @find id)?
              @[iphData][item.id] = item
              @[iphData][item.id]?
          constructor: (asKey, asName) ->
            super asKey, asName
            @[ipsKey] = asKey; @[ipsName] = asName; @[iphData] = {}
        Test::Collection.initialize()
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @attr test: Number
          @attr has: Boolean
        Test::TestRecord.initialize()
        collection = Test::Collection.new KEY
        record = Test::TestRecord.new { test: 1000, has: true }, collection
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
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::Collection extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::CollectionInterface
          @Module: Test
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: LeanRC::Facade,
            get: -> LeanRC::Facade.getInstance KEY
          @public find: Function,
            default: (id) -> RC::Promise.resolve @[iphData][id]
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              if (yield @find item.id)?
                throw new Error "Item '#{item.id}' is already exists"
              item.id ?= RC::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              throw new Error "Item '#{id}' is missing"  unless (yield @find id)?
              @[iphData][item.id] = item
              @[iphData][item.id]?
          constructor: (asKey, asName) ->
            super asKey, asName
            @[ipsKey] = asKey; @[ipsName] = asName; @[iphData] = {}
        Test::Collection.initialize()
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @attr test: Number
          @attr has: Boolean
          @attr word: String
        Test::TestRecord.initialize()
        collection = Test::Collection.new KEY
        record = Test::TestRecord.new { test: 1000, has: true, word: 'test' }, collection
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
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::Collection extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::CollectionInterface
          @Module: Test
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: LeanRC::Facade,
            get: -> LeanRC::Facade.getInstance KEY
          @public find: Function,
            default: (id) -> RC::Promise.resolve @[iphData][id]
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              if (yield @find item.id)?
                throw new Error "Item '#{item.id}' is already exists"
              item.id ?= RC::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              throw new Error "Item '#{id}' is missing"  unless (yield @find id)?
              @[iphData][item.id] = item
              @[iphData][item.id]?
          constructor: (asKey, asName) ->
            super asKey, asName
            @[ipsKey] = asKey; @[ipsName] = asName; @[iphData] = {}
        Test::Collection.initialize()
        class Test::BasicTestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::BasicTestRecord
          @attribute updatedAt: Date
          @attribute test: Number
          @attribute has: Boolean
          @attribute word: String
        Test::BasicTestRecord.initialize()
        class Test::TestRecord extends Test::BasicTestRecord
          @inheritProtected()
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
        Test::TestRecord.initialize()
        collection = Test::Collection.new KEY
        record = Test::TestRecord.new { test: 1000, has: true, word: 'test' }, collection
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
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::Collection extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::CollectionInterface
          @Module: Test
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: LeanRC::Facade,
            get: -> LeanRC::Facade.getInstance KEY
          @public find: Function,
            default: (id) -> RC::Promise.resolve @[iphData][id]
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              if (yield @find item.id)?
                throw new Error "Item '#{item.id}' is already exists"
              item.id ?= RC::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              throw new Error "Item '#{id}' is missing"  unless (yield @find id)?
              @[iphData][item.id] = item
              @[iphData][item.id]?
          constructor: (asKey, asName) ->
            super asKey, asName
            @[ipsKey] = asKey; @[ipsName] = asName; @[iphData] = {}
        Test::Collection.initialize()
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @attr test: Number
          @attr has: Boolean
          @attr word: String
        Test::TestRecord.initialize()
        collection = Test::Collection.new KEY
        record = Test::TestRecord.new { test: 1000, has: true, word: 'test' }, collection
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
      expect ->
        KEY = 'TEST_RECORD_12'
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @attr test: Number
          @attr has: Boolean
          @attr word: String
        Test::TestRecord.initialize()
        record = Test::TestRecord.normalize { test: 1000, has: true, word: 'test' }, {}
        assert.propertyVal record, 'test', 1000, 'Property `test` not defined'
        assert.propertyVal record, 'has', yes, 'Property `has` not defined'
        assert.propertyVal record, 'word', 'test', 'Property `word` not defined'
        assert.deepEqual record.changedAttributes(), {}, 'Attributes are altered'
        snapshot = Test::TestRecord.serialize record
        assert.deepEqual snapshot, { test: 1000, has: true, word: 'test' }, 'Snapshot is incorrect'
      .to.not.throw Error
