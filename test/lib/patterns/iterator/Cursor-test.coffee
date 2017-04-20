{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Cursor = LeanRC::Cursor

describe 'Cursor', ->
  describe '.new', ->
    it 'should create entry instance', ->
      expect ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        array = [ Test::TestRecord.new(), Test::TestRecord.new(), Test::TestRecord.new() ]
        entry = Cursor.new Test::TestRecord, array
      .to.not.throw Error
