{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
RC = require 'RC'
Cursor = LeanRC::Cursor
{ co } = RC::Utils

describe 'Cursor', ->
  describe '.new', ->
    it 'should create cursor instance', ->
      expect ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        array = [ {}, {}, {} ]
        cursor = Cursor.new Test::TestRecord, array
      .to.not.throw Error
  describe '#setRecord', ->
    it 'should setup record', ->
      expect ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        cursor = Cursor.new()
        cursor.setRecord Test::TestRecord
      .to.not.throw Error
  describe '#next', ->
    it 'should get next values one by one', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
          @attribute data: String, { default: '' }
        Test::TestRecord.initialize()
        array = [ { data: 'three' }, { data: 'men' }, { data: 'in' }, { data: 'a boat' } ]
        cursor = Cursor.new Test::TestRecord, array
        assert.equal (yield cursor.next()).data, 'three', 'First item is incorrect'
        assert.equal (yield cursor.next()).data, 'men', 'Second item is incorrect'
        assert.equal (yield cursor.next()).data, 'in', 'Third item is incorrect'
        assert.equal (yield cursor.next()).data, 'a boat', 'Fourth item is incorrect'
        assert.isUndefined (yield cursor.next()), 'Unexpected item is present'
