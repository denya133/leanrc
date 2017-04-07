{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'
Record = LeanRC::Record

describe 'Record', ->
  ###
  describe '.new', ->
    it 'should create record instance', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
        Test::TestRecord.initialize()
        record = Test::TestRecord.new {}
        console.log 'Schema:', Record.schema
      .to.not.throw Error
  ###
