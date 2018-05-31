{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'HttpSerializerMixin', ->
  describe '#normalize', ->
    it "should normalize object value", ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attribute string: String
          @attribute number: Number
          @attribute boolean: Boolean
        TestRecord.initialize()
        class HttpSerializer extends LeanRC::Serializer
          @inheritProtected()
          @include LeanRC::HttpSerializerMixin
          @module Test
        HttpSerializer.initialize()
        serializer = HttpSerializer.new()
        record = yield serializer.normalize Test::TestRecord,
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        assert.instanceOf record, TestRecord, 'Normalize is incorrect'
        assert.include record,
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        yield return
  describe '#serialize', ->
    it "should serialize Record.prototype value", ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @attribute string: String
          @attribute number: Number
          @attribute boolean: Boolean
        TestRecord.initialize()
        class HttpSerializer extends LeanRC::Serializer
          @inheritProtected()
          @include LeanRC::HttpSerializerMixin
          @module Test
        HttpSerializer.initialize()
        serializer = HttpSerializer.new()
        data = yield serializer.serialize Test::TestRecord.new
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        assert.instanceOf data, Object, 'Serialize is incorrect'
        assert.include data.test,
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        yield return
