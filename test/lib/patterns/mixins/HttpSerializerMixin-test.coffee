{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{
  FuncG, SubsetG
  RecordInterface
  Utils: { co }
} = LeanRC::

describe 'HttpSerializerMixin', ->
  describe '#normalize', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it "should normalize object value", ->
      co ->
        KEY = 'TEST_HTTP_SERIALIZER_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> TestRecord
          @attribute string: String
          @attribute number: Number
          @attribute boolean: Boolean
          @initialize()
        class HttpSerializer extends LeanRC::Serializer
          @inheritProtected()
          @include LeanRC::HttpSerializerMixin
          @module Test
          @initialize()
        boundCollection = TestsCollection.new 'TestsCollection',
          delegate: 'TestRecord'
        facade.registerProxy boundCollection
        serializer = HttpSerializer.new boundCollection
        record = yield serializer.normalize TestRecord,
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
    facade = null
    afterEach ->
      facade?.remove?()
    it "should serialize Record.prototype value", ->
      co ->
        KEY = 'TEST_HTTP_SERIALIZER_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> TestRecord
          @attribute string: String
          @attribute number: Number
          @attribute boolean: Boolean
          @initialize()
        class HttpSerializer extends LeanRC::Serializer
          @inheritProtected()
          @include LeanRC::HttpSerializerMixin
          @module Test
          @initialize()
        boundCollection = TestsCollection.new 'TestsCollection',
          delegate: 'TestRecord'
        facade.registerProxy boundCollection
        serializer = HttpSerializer.new boundCollection
        data = yield serializer.serialize TestRecord.new {
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        }, boundCollection
        assert.instanceOf data, Object, 'Serialize is incorrect'
        assert.include data.test,
          type: 'Test::TestRecord'
          string: 'string'
          number: 123
          boolean: yes
        yield return
