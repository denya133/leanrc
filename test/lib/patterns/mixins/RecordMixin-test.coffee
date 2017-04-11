{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'
RecordMixin = LeanRC::RecordMixin

describe 'RecordMixin', ->
  describe '.new', ->
    it 'should create item with record mixin', ->
      expect ->
        class Test extends RC::Module
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
        class Test extends RC::Module
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
        class Test extends RC::Module
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
        class Test extends RC::Module
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
        class Test extends RC::Module
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
        class Test extends RC::Module
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
  describe '.belongsTo', ->
    it 'should define one-to-one or one-to-many relation for class', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @belongsTo relation: LeanRC::Record,
            attr: 'relation_attr'
            refKey: 'id'
            get: (aoData) -> aoData
            set: (aoData) -> aoData
            transform: LeanRC::Transform
            through: 'Test'
            inverse: 'test'
            valuable: yes
            sortable: yes
            groupable: yes
            filterable: yes
        Test::TestRecord.initialize()
        { relation: relationData } = Test::TestRecord.relations
        assert.isTrue relationData.valuable, 'Value of `valuable` is incorrect'
        assert.isTrue relationData.sortable, 'Value of `sortable` is incorrect'
        assert.isTrue relationData.groupable, 'Value of `groupable` is incorrect'
        assert.isTrue relationData.filterable, 'Value of `filterable` is incorrect'
        assert.equal relationData.transform, LeanRC::Transform, 'Value of `transform` is incorrect'
        assert.equal relationData.relation, 'belongsTo', 'Value of `relation` is incorrect'
        assert.equal relationData.attr, 'relation', 'Value of `attr` is incorrect'
        assert.equal relationData.level, 'PUBLIC', 'Value of `level` is incorrect'
      .to.not.throw Error
  describe '.hasMany', ->
    it 'should define one-to-one or one-to-many relation for class', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @hasMany manyRelation: LeanRC::Record,
            attr: 'relation_attr_many'
            refKey: 'id'
            transform: LeanRC::Transform
            through: 'Test'
            inverse: 'test'
            valuable: yes
            sortable: yes
            groupable: yes
            filterable: yes
        Test::TestRecord.initialize()
        { manyRelation: relationData } = Test::TestRecord.relations
        assert.isTrue relationData.valuable, 'Value of `valuable` is incorrect'
        assert.isTrue relationData.sortable, 'Value of `sortable` is incorrect'
        assert.isTrue relationData.groupable, 'Value of `groupable` is incorrect'
        assert.isTrue relationData.filterable, 'Value of `filterable` is incorrect'
        assert.equal relationData.transform, LeanRC::Transform, 'Value of `transform` is incorrect'
        assert.equal relationData.relation, 'hasMany', 'Value of `relation` is incorrect'
        assert.equal relationData.attr, 'manyRelation', 'Value of `attr` is incorrect'
        assert.equal relationData.level, 'PUBLIC', 'Value of `level` is incorrect'
      .to.not.throw Error
  describe '.hasOne', ->
    it 'should define many-to-one or many-to-one relation for class', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @hasOne oneRelation: LeanRC::Record,
            attr: 'relation_attr_one'
            refKey: 'id'
            transform: LeanRC::Transform
            through: 'Test'
            inverse: 'test'
            valuable: yes
            sortable: yes
            groupable: yes
            filterable: yes
        Test::TestRecord.initialize()
        { oneRelation: relationData } = Test::TestRecord.relations
        assert.isTrue relationData.valuable, 'Value of `valuable` is incorrect'
        assert.isTrue relationData.sortable, 'Value of `sortable` is incorrect'
        assert.isTrue relationData.groupable, 'Value of `groupable` is incorrect'
        assert.isTrue relationData.filterable, 'Value of `filterable` is incorrect'
        assert.equal relationData.transform, LeanRC::Transform, 'Value of `transform` is incorrect'
        assert.equal relationData.relation, 'hasOne', 'Value of `relation` is incorrect'
        assert.equal relationData.attr, 'oneRelation', 'Value of `attr` is incorrect'
        assert.equal relationData.level, 'PUBLIC', 'Value of `level` is incorrect'
      .to.not.throw Error
  describe '.inverseFor', ->
    it 'should get inverse info', ->
      expect ->
        class Test extends RC::Module
        class Test::Relation extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @hasOne test: LeanRC::Record,
            inverse: 'relation'
        Test::Relation.initialize()
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @belongsTo relation: LeanRC::Record,
            attr: 'relation_attr'
            refKey: 'id'
            inverse: 'test'
        Test::TestRecord.initialize()
        inverseInfo = Test::TestRecord.inverseFor 'relation'
        assert.equal inverseInfo.recordClass, Test::Relation, 'Record class is incorrect'
        assert.equal inverseInfo.attrName,'test', 'Record class is incorrect'
        assert.equal inverseInfo.relation, 'hasOne', 'Record class is incorrect'
      .to.not.throw Error
  describe '#create, #isNew', ->
    it 'should create new record', ->
      expect ->
        KEY = 'TEST_RECORD_01'
        class Test extends RC::Module
        class Test::Collection extends RC::CoreObject
          @inheritProtected()
          @Module: Test
          @inheritProtected()
          @include LeanRC::CollectionInterface
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: LeanRC::Facade,
            get: -> LeanRC::Facade.getInstance KEY
          @public push: Function,
            default: (item) ->
              if @[iphData][item?.id]?
                throw new Error 'EXISTS'
              else
                item.id ?= RC::Utils.uuid.v4()
                @[iphData][item.id] = item
              @[iphData][item.id]?
          @public includes: Function,
            default: (id) -> @[iphData][id]?
          constructor: (asKey, asName) ->
            super asKey, asName
            @[ipsKey] = asKey
            @[ipsName] = asName
            @[iphData] = {}
        Test::Collection.initialize()
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
        Test::TestRecord.initialize()
        record = Test::TestRecord.new {}, Test::Collection.new KEY
        assert.isTrue record.isNew(), 'Record is not new'
        record.create()
        assert.isFalse record.isNew(), 'Record is still new'
        assert.throws (-> record.create()), Error, 'Document is exist in collection', 'Record not created'
      .to.not.throw Error
  describe '#destroy', ->
    it 'should remove record', ->
      expect ->
        KEY = 'TEST_RECORD_02'
        class Test extends RC::Module
        class Test::Collection extends RC::CoreObject
          @inheritProtected()
          @Module: Test
          @inheritProtected()
          @include LeanRC::CollectionInterface
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: LeanRC::Facade,
            get: -> LeanRC::Facade.getInstance KEY
          @public push: Function,
            default: (item) ->
              if @[iphData][item?.id]?
                throw new Error 'EXISTS'
              else
                item.id ?= RC::Utils.uuid.v4()
                @[iphData][item.id] = item
              @[iphData][item.id]?
          @public remove: Function,
            default: (query) ->
              { '@doc._key': { $eq: id }} = query
              Reflect.deleteProperty @[iphData], id
          @public includes: Function,
            default: (id) -> @[iphData][id]?
          constructor: (asKey, asName) ->
            super asKey, asName
            @[ipsKey] = asKey
            @[ipsName] = asName
            @[iphData] = {}
        Test::Collection.initialize()
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
        Test::TestRecord.initialize()
        collection = Test::Collection.new KEY
        record = Test::TestRecord.new {}, collection
        assert.isTrue record.isNew(), 'Record is not new'
        record.create()
        assert.isFalse record.isNew(), 'Record is still new'
        record.destroy()
        assert.isFalse collection.includes(record.id), 'Record still in collection'
      .to.not.throw Error
  describe '#update', ->
    it 'should update record', ->
      expect ->
        KEY = 'TEST_RECORD_03'
        class Test extends RC::Module
        class Test::Collection extends RC::CoreObject
          @inheritProtected()
          @Module: Test
          @inheritProtected()
          @include LeanRC::CollectionInterface
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: LeanRC::Facade,
            get: -> LeanRC::Facade.getInstance KEY
          @public find: Function,
            default: (id) -> @[iphData][id]
          @public clone: Function,
            default: (item) ->
              result = item.constructor.new item, @
              for key of item.constructor.attributes
                result[key] = item[key]
              for key of item.constructor.edges
                result[key] = item[key]
              for key of item.constructor.computeds
                result[key] = item[key]
              for key of item.constructor.relations
                result[key] = item[key]
              result.id = RC::Utils.uuid.v4()
              result
          @public push: Function,
            default: (item) ->
              if @includes item.id
                throw new Error 'EXISTS'
              else
                item.id ?= RC::Utils.uuid.v4()
                @[iphData][item.id] = @clone item
              @[iphData][item.id]?
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              if @includes id
                @[iphData][item.id] = @clone item
              else
                throw new Error "Item '#{id}' is missing"
              @[iphData][item.id]?
          @public includes: Function,
            default: (id) -> @[iphData][id]?
          constructor: (asKey, asName) ->
            super asKey, asName
            @[ipsKey] = asKey
            @[ipsName] = asName
            @[iphData] = {}
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
        record.create()
        assert.equal collection.find(record.id).test, 'test1', 'Initial attr not saved'
        record.test = 'test2'
        record.update()
        assert.equal collection.find(record.id).test, 'test2', 'Updated attr not saved'
      .to.not.throw Error
  describe '#clone', ->
    it 'should clone record', ->
      expect ->
        KEY = 'TEST_RECORD_04'
        class Test extends RC::Module
        class Test::Collection extends RC::CoreObject
          @inheritProtected()
          @Module: Test
          @inheritProtected()
          @include LeanRC::CollectionInterface
          ipsKey = @protected key: String
          ipsName = @protected name: String
          iphData = @protected data: Object
          @public facade: LeanRC::Facade,
            get: -> LeanRC::Facade.getInstance KEY
          @public find: Function,
            default: (id) -> @[iphData][id]
          @public clone: Function,
            default: (item) ->
              result = item.constructor.new item, @
              for key of item.constructor.attributes
                result[key] = item[key]
              for key of item.constructor.edges
                result[key] = item[key]
              for key of item.constructor.computeds
                result[key] = item[key]
              for key of item.constructor.relations
                result[key] = item[key]
              result.id = RC::Utils.uuid.v4()
              result
          @public push: Function,
            default: (item) ->
              if @includes item.id
                throw new Error 'EXISTS'
              else
                item.id ?= RC::Utils.uuid.v4()
                @[iphData][item.id] = @clone item
              @[iphData][item.id]?
          @public includes: Function,
            default: (id) -> @[iphData][id]?
          constructor: (asKey, asName) ->
            super asKey, asName
            @[ipsKey] = asKey
            @[ipsName] = asName
            @[iphData] = {}
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
