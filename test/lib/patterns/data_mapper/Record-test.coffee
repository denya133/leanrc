{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
RC = require 'RC'
LeanRC = require.main.require 'lib'
Record = LeanRC::Record
{ co } = RC::Utils

describe 'Record', ->
  describe '.new', ->
    it 'should create record instance', ->
      expect ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        record = Test::TestRecord.new {}
        assert.instanceOf record, Test::TestRecord, 'Not a TestRecord'
        assert.instanceOf record, LeanRC::Record, 'Not a Record'
      .to.not.throw Error
  describe '#afterCreate', ->
    it 'should be called after create', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public @async push: Function,
            default: (record) ->
              record._key ?= RC::Utils.uuid.v4()
              @data.push record
              yield return
          @public @async patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
          @public @async take: Function,
            default: (id) ->
              yield RC::Promise.resolve _.find @data, { id }
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION_02'
        facade = LeanRC::Facade.getInstance 'TEST_RECORD_FACADE_01'
        facade.registerProxy collection
        spyRunNotitfication = sinon.spy collection, 'recordHasBeenChanged'
        record = collection.build {_key: 123}
        yield record.save()
        assert.isTrue spyRunNotitfication.calledWith('createdRecord'), '`afterCreate` run incorrect'
  describe '#beforeUpdate', ->
    it 'should be called before update', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public @async push: Function,
            default: (record) ->
              record._key ?= RC::Utils.uuid.v4()
              @data.push record
              yield return
          @public @async patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
          @public @async take: Function,
            default: (id) ->
              yield RC::Promise.resolve _.find @data, { id }
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION_03'
        facade = LeanRC::Facade.getInstance 'TEST_RECORD_FACADE_02'
        facade.registerProxy collection
        record = collection.build {_key: 123}
        yield record.save()
        oldUpdatedAt = record.updatedAt
        updated = yield record.save()
        newUpdatedAt = record.updatedAt
        assert.notEqual oldUpdatedAt, newUpdatedAt, 'Record not updated'
  describe '#afterUpdate', ->
    it 'should be called after update', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public @async push: Function,
            default: (record) ->
              record._key ?= RC::Utils.uuid.v4()
              @data.push record
              yield return
          @public @async patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
          @public @async take: Function,
            default: (id) ->
              yield RC::Promise.resolve _.find @data, { id }
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION_04'
        facade = LeanRC::Facade.getInstance 'TEST_RECORD_FACADE_03'
        facade.registerProxy collection
        spyRunNotitfication = sinon.spy collection, 'recordHasBeenChanged'
        record = collection.build {_key: 123}
        yield record.save()
        updated = yield record.save()
        assert.isTrue spyRunNotitfication.calledWith('updatedRecord'), '`afterUpdate` run incorrect'
  describe '#beforeDelete', ->
    it 'should be called before delete', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public @async push: Function,
            default: (record) ->
              record._key ?= RC::Utils.uuid.v4()
              @data.push record
              yield return
          @public @async patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
          @public @async take: Function,
            default: (id) ->
              yield RC::Promise.resolve _.find @data, { id }
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION_05'
        facade = LeanRC::Facade.getInstance 'TEST_RECORD_FACADE_04'
        facade.registerProxy collection
        record = collection.build {_key: 123}
        yield record.save()
        oldUpdatedAt = record.updatedAt
        deleted = yield record.delete()
        newUpdatedAt = record.updatedAt
        assert.notEqual oldUpdatedAt, newUpdatedAt, 'Record not updated'
        assert.isDefined deleted.deletedAt, 'Record not deleted'
        assert.isTrue deleted.isHidden, 'Record not hidden'
  describe '#afterDelete', ->
    it 'should be called after delete', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public @async push: Function,
            default: (record) ->
              record._key ?= RC::Utils.uuid.v4()
              @data.push record
              yield return
          @public @async patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
          @public @async take: Function,
            default: (id) ->
              yield RC::Promise.resolve _.find @data, { id }
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION_04'
        facade = LeanRC::Facade.getInstance 'TEST_RECORD_FACADE_03'
        facade.registerProxy collection
        spyRunNotitfication = sinon.spy collection, 'recordHasBeenChanged'
        record = collection.build {_key: 123}
        yield record.save()
        deleted = yield record.delete()
        assert.isTrue spyRunNotitfication.calledWith('deletedRecord'), '`afterDelete` run incorrect'
  describe '#afterDestroy', ->
    it 'should be called after destroy', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public @async push: Function,
            default: (record) ->
              record._key ?= RC::Utils.uuid.v4()
              @data.push record
              yield return
          @public @async take: Function,
            default: (id) ->
              yield RC::Promise.resolve _.find @data, { id }
          @public @async remove: Function,
            default: (id) ->
              yield RC::Promise.resolve _.remove @data, { id }
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION_04'
        facade = LeanRC::Facade.getInstance 'TEST_RECORD_FACADE_03'
        facade.registerProxy collection
        spyRunNotitfication = sinon.spy collection, 'recordHasBeenChanged'
        record = collection.build {_key: 123}
        yield record.save()
        yield record.destroy()
        assert.isTrue spyRunNotitfication.calledWith('destroyedRecord'), '`afterDestroy` run incorrect'
