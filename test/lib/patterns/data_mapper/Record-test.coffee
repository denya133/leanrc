{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'
Record = LeanRC::Record

describe 'Record', ->
  describe '.new', ->
    it 'should create record instance', ->
      expect ->
        class Test extends RC::Module
          @inheritProtected()
        Test.initialize()
        
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        record = Test::TestRecord.new {}
        assert.instanceOf record, Test::TestRecord, 'Not a TestRecord'
        assert.instanceOf record, LeanRC::Record, 'Not a Record'
      .to.not.throw Error
