{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
RC = require 'RC'
LeanRC = require.main.require 'lib'
{ co } = RC::Utils


describe 'Collection', ->
  describe '.new', ->
    it 'should create collection instance', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new {}
        assert.equal collection.delegate, Test::TestRecord, 'Record is incorrect'
      .to.not.throw Error
  describe '#collectionName', ->
    it 'should get collection name', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new {}
        assert.equal collection.collectionName(), 'test_records'
      .to.not.throw Error
  describe '#collectionPrefix', ->
    it 'should get collection prefix', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new {}
        assert.equal collection.collectionPrefix(), 'test_'
      .to.not.throw Error
  describe '#collectionFullName', ->
    it 'should get collection full name', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new {}
        assert.equal collection.collectionFullName(), 'test_test_records'
      .to.not.throw Error
  describe '#recordHasBeenChanged', ->
    it 'should send notification about record changed', ->
      expect ->
        spyHandleNotitfication = sinon.spy ->
        class Test extends RC::Module
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestCollection.initialize()
        class Test::TestMediator extends LeanRC::Mediator
          @inheritProtected()
          @Module: Test
          @public listNotificationInterests: Function,
            default: -> [ LeanRC::Constants.RECORD_CHANGED ]
          @public handleNotification: Function,
            default: spyHandleNotitfication
        Test::TestMediator.initialize()
        facade = LeanRC::Facade.getInstance 'TEST_COLLECTION_01'
        facade.registerProxy Test::TestCollection.new 'TEST_COLLECTION', {}
        collection = facade.retrieveProxy 'TEST_COLLECTION'
        facade.registerMediator Test::TestMediator.new 'TEST_MEDIATOR', {}
        mediator = facade.retrieveMediator 'TEST_MEDIATOR'
        collection.recordHasBeenChanged { test: 'test' }, Test::TestRecord.new()
        assert.isTrue spyHandleNotitfication.called, 'Notification did not received'
      .to.not.throw Error
  describe '#generateId', ->
    it 'should get dummy generated ID', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        assert.isUndefined collection.generateId(), 'Generated ID is defined'
      .to.not.throw Error
  describe '#build', ->
    it 'should create record from delegate', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        record = collection.build test: 'test', data: 123
        assert.equal record.test, 'test', 'Record#test is incorrect'
        assert.equal record.data, 123, 'Record#data is incorrect'
      .to.not.throw Error
  describe '#create', ->
    it 'should create record in collection', ->
      co ->
        spyCollectionPush = sinon.spy -> yield return
        class Test extends RC::Module
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public push: Function,
            default: spyCollectionPush
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        record = yield collection.create test: 'test', data: 123
        assert.isDefined record, 'Record not created'
        assert.isTrue spyCollectionPush.called, 'Record not saved'
  describe '#update', ->
    it 'should delete record from collection', ->
      co ->
        spyCollectionPush = sinon.spy (record) ->
          record._key = RC::Utils.uuid.v4()
          @data.push record
          yield return
        class Test extends RC::Module
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
          @public find: Function,
            default: (id) -> yield RC::Promise.resolve _.find @data, { id }
          @public push: Function,
            default: spyCollectionPush
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        record = yield collection.create test: 'test', data: 123
        record.data = 456
        yield record.update()
        assert.equal (yield collection.find record.id).data, 456, 'Record not updated'
  describe '#delete', ->
    it 'should delete record from collection', ->
      co ->
        spyCollectionPush = sinon.spy (record) ->
          record._key = RC::Utils.uuid.v4()
          @data.push record
          yield return
        class Test extends RC::Module
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
          @public find: Function,
            default: (id) -> yield RC::Promise.resolve _.find @data, { id }
          @public push: Function,
            default: spyCollectionPush
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        record = yield collection.create test: 'test', data: 123
        yield record.delete()
        assert.isFalse yield record.isNew(), 'Record not saved'
        assert.isTrue record.isHidden, 'Record not hidden'
