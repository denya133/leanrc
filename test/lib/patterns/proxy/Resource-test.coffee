{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
RC = require 'RC'
LeanRC = require.main.require 'lib'
{ co } = RC::Utils


describe 'Resource', ->
  describe '.new', ->
    it 'should create resource instance', ->
      expect ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestResource.initialize()
        resource = Test::TestResource.new {}
        assert.equal resource.delegate, Test::TestRecord, 'Record is incorrect'
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
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestResource.initialize()
        resource = Test::TestResource.new {}
        assert.equal resource.collectionName(), 'test_records'
      .to.not.throw Error
  describe '#collectionPrefix', ->
    it 'should get resource prefix', ->
      expect ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestResource.initialize()
        resource = Test::TestResource.new {}
        assert.equal resource.collectionPrefix(), 'test_'
      .to.not.throw Error
  describe '#collectionFullName', ->
    it 'should get resource full name', ->
      expect ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestResource.initialize()
        resource = Test::TestResource.new {}
        assert.equal resource.collectionFullName(), 'test_test_records'
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
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestResource.initialize()
        class Test::TestMediator extends LeanRC::Mediator
          @inheritProtected()
          @module Test
          @public listNotificationInterests: Function,
            default: -> [ LeanRC::RECORD_CHANGED ]
          @public handleNotification: Function,
            default: spyHandleNotitfication
        Test::TestMediator.initialize()
        facade = LeanRC::Facade.getInstance 'TEST_RESOURCE_01'
        facade.registerProxy Test::TestResource.new 'TEST_RESOURCE', {}
        resource = facade.retrieveProxy 'TEST_RESOURCE'
        facade.registerMediator Test::TestMediator.new 'TEST_MEDIATOR', {}
        mediator = facade.retrieveMediator 'TEST_MEDIATOR'
        resource.recordHasBeenChanged { test: 'test' }, Test::TestRecord.new()
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
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestResource.initialize()
        resource = Test::TestResource.new 'TEST_RESOURCE', {}
        assert.isUndefined resource.generateId(), 'Generated ID is defined'
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
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestResource.initialize()
        collection = Test::TestResource.new 'TEST_RESOURCE', {}
        record = collection.build test: 'test', data: 123
        assert.equal record.test, 'test', 'Record#test is incorrect'
        assert.equal record.data, 123, 'Record#data is incorrect'
      .to.not.throw Error
  describe '#create', ->
    it 'should create record in resource', ->
      co ->
        spyResourcePush = sinon.spy -> yield return
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute data: Number
        Test::TestRecord.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public push: Function,
            default: spyResourcePush
        Test::TestResource.initialize()
        resource = Test::TestResource.new 'TEST_RESOURCE', {}
        LeanRC::Facade.getInstance('TEST_RESOURCE_FACADE_01').registerProxy resource
        record = yield resource.create test: 'test', data: 123
        assert.isDefined record, 'Record not created'
        assert.isTrue spyResourcePush.called, 'Record not saved'
  describe '#update', ->
    it 'should update record in resource', ->
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
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
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
          @public take: Function,
            default: (id) -> yield RC::Promise.resolve _.find @data, { id }
          @public push: Function,
            default: (record) ->
              record._key = RC::Utils.uuid.v4()
              @data.push record
              yield return
        Test::TestResource.initialize()
        resource = Test::TestResource.new 'TEST_RESOURCE', {}
        LeanRC::Facade.getInstance('TEST_RESOURCE_FACADE_02').registerProxy resource
        record = yield resource.create test: 'test', data: 123
        record.data = 456
        yield record.update()
        assert.equal (yield resource.find record.id).data, 456, 'Record not updated'
  describe '#delete', ->
    it 'should delete record from resource', ->
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
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
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
          @public take: Function,
            default: (id) -> yield RC::Promise.resolve _.find @data, { id }
          @public push: Function,
            default: (record) ->
              record._key = RC::Utils.uuid.v4()
              @data.push record
              yield return
        Test::TestResource.initialize()
        resource = Test::TestResource.new 'TEST_RESOURCE', {}
        LeanRC::Facade.getInstance('TEST_RESOURCE_FACADE_03').registerProxy resource
        record = yield resource.create test: 'test', data: 123
        yield record.delete()
        assert.isFalse yield record.isNew(), 'Record not saved'
        assert.isTrue record.isHidden, 'Record not hidden'
  describe '#destroy', ->
    it 'should destroy record from resource', ->
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
        class Test::TestResource extends LeanRC::Resource
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
              record._key = RC::Utils.uuid.v4()
              @data.push record
              yield return
        Test::TestResource.initialize()
        resource = Test::TestResource.new 'TEST_RESOURCE', {}
        LeanRC::Facade.getInstance('TEST_RESOURCE_FACADE_04').registerProxy resource
        record = yield resource.create test: 'test', data: 123
        yield record.destroy()
        assert.isFalse (yield resource.find record.id)?, 'Record removed'
  describe '#find', ->
    it 'should find record from resource', ->
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
        class Test::TestResource extends LeanRC::Resource
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
              record._key = RC::Utils.uuid.v4()
              @data.push record
              yield return
        Test::TestResource.initialize()
        resource = Test::TestResource.new 'TEST_RESOURCE', {}
        LeanRC::Facade.getInstance('TEST_RESOURCE_FACADE_05').registerProxy resource
        record = yield resource.create test: 'test', data: 123
        record2 = yield resource.find record.id
        assert.equal record.test, record2.test, 'Record not found'
  describe '#findMany', ->
    it 'should find many records from resource', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
        Test::TestRecord.initialize()
        class Test::TestResource extends LeanRC::Resource
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
              record._key = RC::Utils.uuid.v4()
              @data.push record
              yield return
        Test::TestResource.initialize()
        resource = Test::TestResource.new 'TEST_RESOURCE', {}
        LeanRC::Facade.getInstance('TEST_RESOURCE_FACADE_06').registerProxy resource
        { id: id1 } = yield resource.create test: 'test1'
        { id: id2 } = yield resource.create test: 'test2'
        { id: id3 } = yield resource.create test: 'test3'
        records = yield resource.findMany [ id1, id2, id3 ]
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
        class Test::TestResource extends LeanRC::Resource
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
              record._key = RC::Utils.uuid.v4()
              @data.push record
              yield return
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
        Test::TestResource.initialize()
        resource = Test::TestResource.new 'TEST_RESOURCE', {}
        LeanRC::Facade.getInstance('TEST_RESOURCE_FACADE_07').registerProxy resource
        { id } = yield resource.create test: 'test1', data: 123
        record = yield resource.replace id, test: 'test2', data: 456
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
        class Test::TestResource extends LeanRC::Resource
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
              record._key = RC::Utils.uuid.v4()
              @data.push record
              yield return
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
        Test::TestResource.initialize()
        resource = Test::TestResource.new 'TEST_RESOURCE', {}
        LeanRC::Facade.getInstance('TEST_RESOURCE_FACADE_08').registerProxy resource
        { id } = yield resource.create test: 'test1', data: 123
        record = yield resource.update id, test: 'test2', data: 456
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
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public data: Array,
            default: []
          @public generateId: Function,
            default: -> RC::Utils.uuid.v4()
        Test::TestResource.initialize()
        resource = Test::TestResource.new 'TEST_RESOURCE', {}
        LeanRC::Facade.getInstance('TEST_RESOURCE_FACADE_09').registerProxy resource
        original = resource.build test: 'test', data: 123
        clone = resource.clone original
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
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestResource extends LeanRC::Resource
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
              record._key ?= RC::Utils.uuid.v4()
              @data.push record
              yield return
          @public patch: Function,
            default: (query, item) ->
              { '@doc._key': { '$eq': id }} = query
              record = yield @find id
              record[key] = value  for own key, value of item
              yield return record?
          @public generateId: Function,
            default: -> RC::Utils.uuid.v4()
        Test::TestResource.initialize()
        resource = Test::TestResource.new 'TEST_RESOURCE', {}
        LeanRC::Facade.getInstance('TEST_RESOURCE_FACADE_10').registerProxy resource
        original = resource.build test: 'test', data: 123
        clone = yield resource.copy original
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
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public serializer: Object,
            default: normalize: spySerializerNormalize
        Test::TestResource.initialize()
        resource = Test::TestResource.new 'TEST_RESOURCE', {}
        LeanRC::Facade.getInstance('TEST_RESOURCE_FACADE_11').registerProxy resource
        record = resource.normalize test: 'test', data: 123
        assert.isTrue spySerializerNormalize.calledWith(Test::TestRecord, test: 'test', data: 123), 'Normalize called improperly'
  describe '#normalize', ->
    it 'should normalize record from data', ->
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
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public delegate: RC::Class,
            default: Test::TestRecord
          @public serializer: Object,
            default: serialize: spySerializerSerialize
        Test::TestResource.initialize()
        resource = Test::TestResource.new 'TEST_RESOURCE', {}
        LeanRC::Facade.getInstance('TEST_RESOURCE_FACADE_12').registerProxy resource
        record = resource.build test: 'test', data: 123
        data = resource.serialize record, value: 'value'
        assert.isTrue spySerializerSerialize.calledWith(record, value: 'value'), 'Serialize called improperly'
