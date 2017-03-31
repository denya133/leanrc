{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'


describe 'Collection', ->
  describe '.new', ->
    it 'should create collection instance', ->
      expect ->
        class Test
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new {}
        assert.equal collection.delegate, Test::TestRecord
      .to.not.throw Error
