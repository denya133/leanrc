{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'


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
