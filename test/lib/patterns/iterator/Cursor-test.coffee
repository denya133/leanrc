{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Cursor = LeanRC::Cursor

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
        array = [ Test::TestRecord.new(), Test::TestRecord.new(), Test::TestRecord.new() ]
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
