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
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        record = Test::TestRecord.new {}
        assert.instanceOf record, Test::TestRecord, 'Not a TestRecord'
        assert.instanceOf record, LeanRC::Record, 'Not a Record'
      .to.not.throw Error
  describe '#afterCreate', ->
    it 'should be called after create', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION_02',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_RECORD_FACADE_01'
        facade.registerProxy collection
        spyRunNotitfication = sinon.spy collection, 'recordHasBeenChanged'
        record = collection.build {id: 123}
        yield record.save()
        assert.isTrue spyRunNotitfication.calledWith('createdRecord'), '`afterCreate` run incorrect'
        facade.remove()
  describe '#beforeUpdate', ->
    it 'should be called before update', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION_03',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_RECORD_FACADE_02'
        facade.registerProxy collection
        record = collection.build {id: 123}
        yield record.save()
        oldUpdatedAt = record.updatedAt
        updated = yield record.save()
        newUpdatedAt = record.updatedAt
        assert.notEqual oldUpdatedAt, newUpdatedAt, 'Record not updated'
        facade.remove()
  describe '#beforeCreate', ->
    it 'should be called before create', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION_04',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_RECORD_FACADE_03'
        facade.registerProxy collection
        record = collection.build()
        assert.isUndefined record.id
        yield record.save()
        assert.isDefined record.id
        facade.remove()
  describe '#afterUpdate', ->
    it 'should be called after update', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION_05',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_RECORD_FACADE_04'
        facade.registerProxy collection
        spyRunNotitfication = sinon.spy collection, 'recordHasBeenChanged'
        record = collection.build {id: 123}
        yield record.save()
        updated = yield record.save()
        assert.isTrue spyRunNotitfication.calledWith('updatedRecord'), '`afterUpdate` run incorrect'
        facade.remove()
  describe '#beforeDelete', ->
    it 'should be called before delete', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION_06',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_RECORD_FACADE_05'
        facade.registerProxy collection
        record = collection.build {id: 123}
        yield record.save()
        oldUpdatedAt = record.updatedAt
        deleted = yield record.delete()
        newUpdatedAt = record.updatedAt
        assert.notEqual oldUpdatedAt, newUpdatedAt, 'Record not updated'
        assert.isDefined deleted.deletedAt, 'Record not deleted'
        assert.isTrue deleted.isHidden, 'Record not hidden'
        facade.remove()
  describe '#afterDelete', ->
    it 'should be called after delete', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION_07',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_RECORD_FACADE_06'
        facade.registerProxy collection
        spyRunNotitfication = sinon.spy collection, 'recordHasBeenChanged'
        record = collection.build {id: 123}
        yield record.save()
        deleted = yield record.delete()
        assert.isTrue spyRunNotitfication.calledWith('deletedRecord'), '`afterDelete` run incorrect'
        facade.remove()
  describe '#afterDestroy', ->
    it 'should be called after destroy', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION_08',
          delegate: Test::TestRecord
        facade = LeanRC::Facade.getInstance 'TEST_RECORD_FACADE_07'
        facade.registerProxy collection
        spyRunNotitfication = sinon.spy collection, 'recordHasBeenChanged'
        record = collection.build {id: 123}
        yield record.save()
        yield record.destroy()
        assert.isTrue spyRunNotitfication.calledWith('destroyedRecord'), '`afterDestroy` run incorrect'
        facade.remove()
