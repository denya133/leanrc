{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'


describe 'Collection', ->
  ###
  describe '.new', ->
    it 'should create collection instance', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends LeanRC::Record
          @Module: Test
          @inheritProtected()
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @Module: Test
          @inheritProtected()
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new {}
        assert.equal collection.delegate, Test::TestRecord
        console.log '!!!', collection.collectionFullName()
      .to.not.throw Error
  ###
