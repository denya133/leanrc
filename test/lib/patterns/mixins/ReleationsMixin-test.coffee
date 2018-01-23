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
        record = Test::TestRecord.new {}, {}
        assert.instanceOf record, Test::TestRecord, 'record is not a TestRecord instance'
      .to.not.throw Error
  describe '.belongsTo', ->
    it 'should define one-to-one or one-to-many relation for class', ->
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
        assert.equal relationData.level, RC::PUBLIC, 'Value of `level` is incorrect'
        yield return
  describe '.hasMany', ->
    it 'should define one-to-one or one-to-many relation for class', ->
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
        assert.equal relationData.level, RC::PUBLIC, 'Value of `level` is incorrect'
        yield return
  describe '.hasOne', ->
    it 'should define many-to-one or many-to-one relation for class', ->
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
        assert.equal relationData.level, RC::PUBLIC, 'Value of `level` is incorrect'
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
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
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
