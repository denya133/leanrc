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
