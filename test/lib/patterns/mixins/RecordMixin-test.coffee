{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'
RecordMixin = LeanRC::RecordMixin

describe 'RecordMixin', ->
  describe '.new', ->
    it 'should create item with record mixin', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) ->
              Test::TestRecord
        Test::TestRecord.initialize()
        record = Test::TestRecord.new {}, {}
        assert.instanceOf record, Test::TestRecord, 'record is not a TestRecord instance'
      .to.not.throw Error
  describe '.parseRecordName', ->
    it 'should record name from text', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) ->
              Test::TestRecord
        Test::TestRecord.initialize()
        parsedName = Test::TestRecord.parseRecordName 'test-record'
        assert.deepEqual parsedName, ['Test', 'TestRecord'], 'Parsed incorrectly'
        parsedName = Test::TestRecord.parseRecordName 'Tester::Test'
        assert.deepEqual parsedName, ['Tester', 'Test'], 'Parsed incorrectly'
      .to.not.throw Error
  describe '#parseRecordName', ->
    it 'should record name in instance from text', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) ->
              Test::TestRecord
        Test::TestRecord.initialize()
        vsRecord = Test::TestRecord.new()
        parsedName = vsRecord.parseRecordName 'test-record'
        assert.deepEqual parsedName, ['Test', 'TestRecord'], 'Parsed incorrectly'
        parsedName = vsRecord.parseRecordName 'Tester::Test'
        assert.deepEqual parsedName, ['Tester', 'Test'], 'Parsed incorrectly'
      .to.not.throw Error
  describe '.parentClassNames', ->
    it 'should get records class parent class names', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends RC::CoreObject
          @inheritProtected()
          @include LeanRC::RecordMixin
          @Module: Test
          @public @static findModelByName: Function,
            default: (asType) ->
              Test::TestRecord
        Test::TestRecord.initialize()
        classNames = Test::TestRecord.parentClassNames()
        assert.deepEqual classNames, [ 'CoreObject', 'RecordMixin', 'TestRecord' ], 'Parsed incorrectly'
      .to.not.throw Error
