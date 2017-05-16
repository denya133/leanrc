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
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
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
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new {}
        assert.equal collection.collectionName(), 'tests'
      .to.not.throw Error
  describe '#collectionPrefix', ->
    it 'should get collection prefix', ->
      expect ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
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
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new {}
        assert.equal collection.collectionFullName(), 'test_tests'
      .to.not.throw Error
  describe '#recordHasBeenChanged', ->
    it 'should send notification about record changed', ->
      expect ->
        spyHandleNotitfication = sinon.spy ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestCollection.initialize()
        class Test::TestMediator extends LeanRC::Mediator
          @inheritProtected()
          @module Test
          @public listNotificationInterests: Function,
            default: -> [ LeanRC::RECORD_CHANGED ]
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
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
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
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
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
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public push: Function,
            default: spyCollectionPush
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        LeanRC::Facade.getInstance('TEST_COLLECTION_FACADE_01').registerProxy collection
        record = yield collection.create test: 'test', data: 123
        assert.isDefined record, 'Record not created'
        assert.isTrue spyCollectionPush.called, 'Record not saved'
  describe '#update', ->
    it 'should update record in collection', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public patch: Function,
            default: (id, item) ->
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
          @public take: Function,
            default: (id) -> yield RC::Promise.resolve _.find @data, { id }
          @public push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @data.push record
              yield return
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        LeanRC::Facade.getInstance('TEST_COLLECTION_FACADE_02').registerProxy collection
        record = yield collection.create test: 'test', data: 123
        record.data = 456
        yield record.update()
        assert.equal (yield collection.find record.id).data, 456, 'Record not updated'
  describe '#delete', ->
    it 'should delete record from collection', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public patch: Function,
            default: (id, item) ->
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
          @public take: Function,
            default: (id) -> yield RC::Promise.resolve _.find @data, { id }
          @public push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @data.push record
              yield return
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        LeanRC::Facade.getInstance('TEST_COLLECTION_FACADE_03').registerProxy collection
        record = yield collection.create test: 'test', data: 123
        yield record.delete()
        assert.isFalse yield record.isNew(), 'Record not saved'
        assert.isTrue record.isHidden, 'Record not hidden'
  describe '#destroy', ->
    it 'should destroy record from collection', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public remove: Function,
            default: (id) -> yield RC::Promise.resolve _.remove @data, { id }
          @public take: Function,
            default: (id) -> yield RC::Promise.resolve _.find @data, { id }
          @public push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @data.push record
              yield return
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        LeanRC::Facade.getInstance('TEST_COLLECTION_FACADE_04').registerProxy collection
        record = yield collection.create test: 'test', data: 123
        yield record.destroy()
        assert.isFalse (yield collection.find record.id)?, 'Record removed'
  describe '#find', ->
    it 'should find record from collection', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public take: Function,
            default: (id) -> yield RC::Promise.resolve _.find @data, { id }
          @public push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @data.push record
              yield return
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        LeanRC::Facade.getInstance('TEST_COLLECTION_FACADE_05').registerProxy collection
        record = yield collection.create test: 'test', data: 123
        record2 = yield collection.find record.id
        assert.equal record.test, record2.test, 'Record not found'
  describe '#findMany', ->
    it 'should find many records from collection', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public takeMany: Function,
            default: (ids) ->
              for id in ids then yield @take id
          @public take: Function,
            default: (id) -> yield RC::Promise.resolve _.find @data, { id }
          @public push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @data.push record
              yield return
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        LeanRC::Facade.getInstance('TEST_COLLECTION_FACADE_06').registerProxy collection
        { id: id1 } = yield collection.create test: 'test1'
        { id: id2 } = yield collection.create test: 'test2'
        { id: id3 } = yield collection.create test: 'test3'
        records = yield collection.findMany [ id1, id2, id3 ]
        assert.equal records.length, 3, 'Found not the three records'
        assert.equal records[0].test, 'test1', 'First record is incorrect'
        assert.equal records[1].test, 'test2', 'Second record is incorrect'
        assert.equal records[2].test, 'test3', 'Third record is incorrect'
  describe '#replace', ->
    it 'should update record with properties', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public take: Function,
            default: (id) -> yield RC::Promise.resolve _.find @data, { id }
          @public push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @data.push record
              yield return
          @public patch: Function,
            default: (id, item) ->
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        LeanRC::Facade.getInstance('TEST_COLLECTION_FACADE_07').registerProxy collection
        { id } = yield collection.create test: 'test1', data: 123
        record = yield collection.replace id, test: 'test2', data: 456
        assert.equal record.test, 'test2', 'Attribute `test` did not updated'
        assert.equal record.data, 456, 'Attributes `data` did not updated'
  describe '#update', ->
    it 'should update record with properties', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public take: Function,
            default: (id) -> yield RC::Promise.resolve _.find @data, { id }
          @public push: Function,
            default: (record) ->
              record.id = RC::Utils.uuid.v4()
              @data.push record
              yield return
          @public patch: Function,
            default: (id, item) ->
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        LeanRC::Facade.getInstance('TEST_COLLECTION_FACADE_08').registerProxy collection
        { id } = yield collection.create test: 'test1', data: 123
        record = yield collection.update id, test: 'test2', data: 456
        assert.equal record.test, 'test2', 'Attribute `test` did not updated'
        assert.equal record.data, 456, 'Attributes `data` did not updated'
  describe '#clone', ->
    it 'should make record copy with new id without save', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public generateId: Function,
            default: -> RC::Utils.uuid.v4()
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        LeanRC::Facade.getInstance('TEST_COLLECTION_FACADE_09').registerProxy collection
        original = collection.build test: 'test', data: 123
        clone = collection.clone original
        assert.notEqual original, clone, 'Record is not a copy but a reference'
        assert.equal original.test, clone.test, '`test` values are different'
        assert.equal original.data, clone.data, '`data` values are different'
        assert.notEqual original.id, clone.id, '`id` values are the same'
  describe '#copy', ->
    it 'should make record copy with new id with save', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public take: Function,
            default: (id) -> yield RC::Promise.resolve _.find @data, { id }
          @public push: Function,
            default: (record) ->
              record.id ?= RC::Utils.uuid.v4()
              @data.push record
              yield return
          @public patch: Function,
            default: (id, item) ->
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
          @public generateId: Function,
            default: -> RC::Utils.uuid.v4()
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION', {}
        LeanRC::Facade.getInstance('TEST_COLLECTION_FACADE_10').registerProxy collection
        original = collection.build test: 'test', data: 123
        clone = yield collection.copy original
        assert.notEqual original, clone, 'Record is not a copy but a reference'
        assert.equal original.test, clone.test, '`test` values are different'
        assert.equal original.data, clone.data, '`data` values are different'
        assert.notEqual original.id, clone.id, '`id` values are the same'
  describe '#normalize', ->
    it 'should normalize record from data', ->
      co ->
        spySerializerNormalize = sinon.spy ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
          serializer: class Serializer
            @new: (args) -> Reflect.construct @, args
            normalize: spySerializerNormalize
        LeanRC::Facade.getInstance('TEST_COLLECTION_FACADE_11').registerProxy collection
        record = collection.normalize test: 'test', data: 123
        assert.isTrue spySerializerNormalize.calledWith(Test::TestRecord, test: 'test', data: 123), 'Normalize called improperly'
  describe '#serialize', ->
    it 'should serialize record to data', ->
      co ->
        spySerializerSerialize = sinon.spy ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
          serializer: class Serializer
            @new: (args) -> Reflect.construct @, args
            serialize: spySerializerSerialize
        LeanRC::Facade.getInstance('TEST_COLLECTION_FACADE_12').registerProxy collection
        record = collection.build test: 'test', data: 123
        data = collection.serialize record, value: 'value'
        assert.isTrue spySerializerSerialize.calledWith(record, value: 'value'), 'Serialize called improperly'
