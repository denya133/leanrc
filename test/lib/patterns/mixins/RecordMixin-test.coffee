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
            @[ipsKey] = asKey; @[ipsName] = asName; @[iphData] = {}
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
            @[ipsKey] = asKey; @[ipsName] = asName; @[iphData] = {}
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
              result[key] = item[key]  for key of item.constructor.attributes
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
              result[key] = item[key]  for key of item.constructor.attributes
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
      expect ->
        KEY = 'TEST_RECORD_05'
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
              result[key] = item[key]  for key of item.constructor.attributes
              result.id = RC::Utils.uuid.v4()
              result
          @public push: Function,
            default: (item) ->
              if @includes item.id
                throw new Error 'EXISTS'
              else
                item.id ?= RC::Utils.uuid.v4()
                @[iphData][item.id] = item
              @[iphData][item.id]?
          @public includes: Function,
            default: (id) -> @[iphData][id]?
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
        record.save()
        assert.isTrue collection.includes(record.id), 'Record is not saved'
      .to.not.throw Error
  describe '#delete', ->
    it 'should create and then delete a record', ->
      expect ->
        KEY = 'TEST_RECORD_06'
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
          @public push: Function,
            default: (item) ->
              if @includes item.id
                throw new Error 'EXISTS'
              else
                item.id ?= RC::Utils.uuid.v4()
                @[iphData][item.id] = item
              @[iphData][item.id]?
          @public includes: Function,
            default: (id) -> @[iphData][id]? and not @[iphData][id].isHidden
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
        record.save()
        assert.isTrue collection.includes(record.id), 'Record is not saved'
        record.delete()
        assert.isFalse collection.includes(record.id), 'Record is not maked as delete'
      .to.not.throw Error
  describe '#copy', ->
    it 'should create and then copy the record', ->
      expect ->
        KEY = 'TEST_RECORD_07'
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
          @public push: Function,
            default: (item) ->
              if @includes item.id
                throw new Error 'EXISTS'
              else
                item.id ?= RC::Utils.uuid.v4()
                @[iphData][item.id] = item
              @[iphData][item.id]?
          @public includes: Function,
            default: (id) -> @[iphData][id]? and not @[iphData][id].isHidden
          @public clone: Function,
            default: (item) ->
              result = item.constructor.new item, @
              result[key] = item[key]  for key of item.constructor.attributes
              result.id = RC::Utils.uuid.v4()
              result
          @public copy: Function,
            default: (item) ->
              newItem = @clone item
              newItem.save()
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
        record.save()
        assert.isTrue collection.includes(record.id), 'Record is not saved'
        newRecord = record.copy()
        assert.isTrue collection.includes(newRecord.id), 'Record copy not saved'
      .to.not.throw Error
  describe '#decrement, #increment, #toggle', ->
    it 'should decrease/increase value of number attribute and toggle boolean', ->
      expect ->
        KEY = 'TEST_RECORD_08'
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
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              throw new Error "Item '#{item.id}' is already exists"  if @includes item.id
              item.id ?= RC::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              throw new Error "Item '#{id}' is missing"  unless @includes id
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public includes: Function,
            default: (id) -> @[iphData][id]? and not @[iphData][id].isHidden
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
        record.save()
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
      .to.not.throw Error
  describe '#updateAttribute, #updateAttributes', ->
    it 'should update attributes', ->
      expect ->
        KEY = 'TEST_RECORD_09'
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
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              throw new Error "Item '#{item.id}' is already exists"  if @includes item.id
              item.id ?= RC::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              throw new Error "Item '#{id}' is missing"  unless @includes id
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public includes: Function,
            default: (id) -> @[iphData][id]? and not @[iphData][id].isHidden
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
      .to.not.throw Error
  describe '#touch', ->
    it 'should save data with date', ->
      expect ->
        KEY = 'TEST_RECORD_10'
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
          @public push: Function,
            default: (item) ->
              throw new Error 'Item is empty'  unless item?
              throw new Error "Item '#{item.id}' is already exists"  if @includes item.id
              item.id ?= RC::Utils.uuid.v4()
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              throw new Error "Item '#{id}' is missing"  unless @includes id
              @[iphData][item.id] = item
              @[iphData][item.id]?
          @public includes: Function,
            default: (id) -> @[iphData][id]? and not @[iphData][id].isHidden
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
          @attribute updatedAt: Date
          @attribute test: Number
          @attribute has: Boolean
          @attribute word: String
        Test::TestRecord.initialize()
        collection = Test::Collection.new KEY
        record = Test::TestRecord.new { test: 1000, has: true, word: 'test' }, collection
        record.touch()
        assert.equal collection.find(record.id).test, 1000, 'Number attribue not updated correctly'
        assert.equal collection.find(record.id).has, yes, 'Boolean attribue not updated correctly'
        assert.equal collection.find(record.id).word, 'test', 'String attribue not updated correctly'
        assert.isAtMost collection.find(record.id).updatedAt, new Date(), 'Date attribue not updated correctly'
      .to.not.throw Error
