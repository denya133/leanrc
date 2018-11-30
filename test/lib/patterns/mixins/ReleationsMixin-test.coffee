{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
RC = require 'RC'
LeanRC = require.main.require 'lib'
RecordMixin = LeanRC::RecordMixin
{ co } = RC::Utils

describe 'RelationsMixin', ->
  describe '.new', ->
    it 'should create item with record mixin', ->
      expect ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @include LeanRC::RelationsMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) ->
              Test::TestRecord
        Test::TestRecord.initialize()
        record = Test::TestRecord.new {type: 'Test::TestRecord'}, {}
        assert.instanceOf record, Test::TestRecord, 'record is not a TestRecord instance'
      .to.not.throw Error
  describe '.relatedTo', ->
    it 'relatedTo: should define one-to-one or one-to-many optional relation for class', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @include LeanRC::RelationsMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @relatedTo relation: LeanRC::Record,
            attr: 'relation_attr'
            refKey: 'id'
            recordName: -> 'TestRecord'
            collectionName: -> 'TestsCollection'
            through: ['tomatosRels', by: 'cucumberId']
            inverse: 'test'
        Test::TestRecord.initialize()
        { relation: relationData } = Test::TestRecord.relations
        assert.equal relationData.refKey, 'id', 'Value of `refKey` is incorrect'
        assert.equal relationData.attr, 'relation_attr', 'Value of `attr` is incorrect'
        assert.equal relationData.inverse, 'test', 'Value of `inverse` is incorrect'
        assert.equal relationData.relation, 'relatedTo', 'Value of `relation` is incorrect'
        assert.deepEqual relationData.through, ['tomatosRels', by: 'cucumberId'], 'Value of `through` is incorrect'
        assert.isArray relationData.through, 'Value of `through` isn`t array'
        assert.isString relationData.through[0], 'Value of `through[0]` isn`t string'
        assert.isObject relationData.through[1], 'Value of `through[1]` isn`t object'
        assert.isString relationData.through[1].by, 'Value of `through[1].by` isn`t string'
        assert.equal relationData.recordName.call(Test::TestRecord), 'TestRecord', 'Value of `recordName` is incorrect'
        assert.equal relationData.collectionName.call(Test::TestRecord), 'TestsCollection', 'Value of `collectionName` is incorrect'
        yield return
    it 'relatedTo: should define options automatically', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @include LeanRC::RelationsMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @relatedTo cucumber: LeanRC::Record
        Test::TestRecord.initialize()
        { cucumber: relationData } = Test::TestRecord.relations
        assert.equal relationData.attr, 'cucumberId', 'Value of `attr` is incorrect'
        assert.equal relationData.recordName.call(Test::TestRecord), 'CucumberRecord', 'Value of `recordName` is incorrect'
        assert.equal relationData.collectionName.call(Test::TestRecord), 'CucumbersCollection', 'Value of `collectionName` is incorrect'
        assert.equal relationData.inverse, 'tests', 'Value of `inverse` is incorrect'
        yield return
  describe '.belongsTo', ->
    it 'belongsTo: should define one-to-one or one-to-many parent relation for class', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @include LeanRC::RelationsMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @belongsTo relation: LeanRC::Record,
            attr: 'relation_attr'
            refKey: 'id'
            recordName: -> 'TestRecord'
            collectionName: -> 'TestsCollection'
            through: ['tomatosRels', by: 'cucumberId']
            inverse: 'test'
        Test::TestRecord.initialize()
        { relation: relationData } = Test::TestRecord.relations
        assert.equal relationData.refKey, 'id', 'Value of `refKey` is incorrect'
        assert.equal relationData.attr, 'relation_attr', 'Value of `attr` is incorrect'
        assert.equal relationData.inverse, 'test', 'Value of `inverse` is incorrect'
        assert.equal relationData.relation, 'belongsTo', 'Value of `relation` is incorrect'
        assert.deepEqual relationData.through, ['tomatosRels', by: 'cucumberId'], 'Value of `through` is incorrect'
        assert.isArray relationData.through, 'Value of `through` isn`t array'
        assert.isString relationData.through[0], 'Value of `through[0]` isn`t string'
        assert.isObject relationData.through[1], 'Value of `through[1]` isn`t object'
        assert.isString relationData.through[1].by, 'Value of `through[1].by` isn`t string'
        assert.equal relationData.recordName.call(Test::TestRecord), 'TestRecord', 'Value of `recordName` is incorrect'
        assert.equal relationData.collectionName.call(Test::TestRecord), 'TestsCollection', 'Value of `collectionName` is incorrect'
        yield return
    it 'belongsTo: should define options automatically', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @include LeanRC::RelationsMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @belongsTo cucumber: LeanRC::Record
        Test::TestRecord.initialize()
        { cucumber: relationData } = Test::TestRecord.relations
        assert.equal relationData.attr, 'cucumberId', 'Value of `attr` is incorrect'
        assert.equal relationData.recordName.call(Test::TestRecord), 'CucumberRecord', 'Value of `recordName` is incorrect'
        assert.equal relationData.collectionName.call(Test::TestRecord), 'CucumbersCollection', 'Value of `collectionName` is incorrect'
        assert.equal relationData.inverse, 'tests', 'Value of `inverse` is incorrect'
        yield return
  describe '.hasMany', ->
    it 'hasMany: should define one-to-one or one-to-many relation for class', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @include LeanRC::RelationsMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @hasMany manyRelation: LeanRC::Record,
            refKey: 'id'
            recordName: -> 'TestRecord'
            collectionName: -> 'TestsCollection'
            through: ['tomatosRels', by: 'cucumberId']
            inverse: 'test'
        Test::TestRecord.initialize()
        { manyRelation: relationData } = Test::TestRecord.relations
        assert.equal relationData.refKey, 'id', 'Value of `refKey` is incorrect'
        assert.equal relationData.inverse, 'test', 'Value of `inverse` is incorrect'
        assert.equal relationData.relation, 'hasMany', 'Value of `relation` is incorrect'
        assert.deepEqual relationData.through, ['tomatosRels', by: 'cucumberId'], 'Value of `through` is incorrect'
        assert.isArray relationData.through, 'Value of `through` isn`t array'
        assert.isString relationData.through[0], 'Value of `through[0]` isn`t string'
        assert.isObject relationData.through[1], 'Value of `through[1]` isn`t object'
        assert.isString relationData.through[1].by, 'Value of `through[1].by` isn`t string'
        assert.equal relationData.recordName.call(Test::TestRecord), 'TestRecord', 'Value of `recordName` is incorrect'
        assert.equal relationData.collectionName.call(Test::TestRecord), 'TestsCollection', 'Value of `collectionName` is incorrect'
        yield return
  describe '.hasOne', ->
    it 'hasOne: should define many-to-one or many-to-one relation for class', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @include LeanRC::RelationsMixin
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @hasOne oneRelation: LeanRC::Record,
            refKey: 'id'
            recordName: -> 'TestRecord'
            collectionName: -> 'TestsCollection'
            through: ['tomatosRels', by: 'cucumberId']
            inverse: 'test'
        Test::TestRecord.initialize()
        { oneRelation: relationData } = Test::TestRecord.relations
        assert.equal relationData.refKey, 'id', 'Value of `refKey` is incorrect'
        assert.equal relationData.inverse, 'test', 'Value of `inverse` is incorrect'
        assert.equal relationData.relation, 'hasOne', 'Value of `relation` is incorrect'
        assert.deepEqual relationData.through, ['tomatosRels', by: 'cucumberId'], 'Value of `through` is incorrect'
        assert.isArray relationData.through, 'Value of `through` isn`t array'
        assert.isString relationData.through[0], 'Value of `through[0]` isn`t string'
        assert.isObject relationData.through[1], 'Value of `through[1]` isn`t object'
        assert.isString relationData.through[1].by, 'Value of `through[1].by` isn`t string'
        assert.equal relationData.recordName.call(Test::TestRecord), 'TestRecord', 'Value of `recordName` is incorrect'
        assert.equal relationData.collectionName.call(Test::TestRecord), 'TestsCollection', 'Value of `collectionName` is incorrect'
        yield return
  describe '.inverseFor', ->
    it 'should get inverse info', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::RelationRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @include LeanRC::RelationsMixin
          @module Test
          @hasOne test: LeanRC::RecordInterface,
            inverse: 'relation'
        Test::RelationRecord.initialize()
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @include LeanRC::RelationsMixin
          @module Test
          @belongsTo relation: LeanRC::RecordInterface,
            attr: 'relation_attr'
            refKey: 'id'
            inverse: 'test'
        Test::TestRecord.initialize()
        inverseInfo = Test::TestRecord.inverseFor 'relation'
        assert.equal inverseInfo.recordClass, Test::RelationRecord, 'Record class is incorrect'
        assert.equal inverseInfo.attrName,'test', 'Record class is incorrect'
        assert.equal inverseInfo.relation, 'hasOne', 'Record class is incorrect'
        yield return
