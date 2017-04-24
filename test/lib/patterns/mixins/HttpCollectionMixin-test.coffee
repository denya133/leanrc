{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
RC = require 'RC'
{ co } = RC::Utils

commonServerInitializer = require.main.require 'test/common/server'
server = commonServerInitializer fixture: 'HttpCollectionMixin'

describe 'HttpCollectionMixin', ->
  describe '.new', ->
    it 'should create HTTP collection instance', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
        Test::HttpCollection.initialize()
        collection = Test::HttpCollection.new()
        assert.instanceOf collection, Test::HttpCollection
        yield return
  describe '#', ->
    before ->
      server.listen 8000
    after ->
      server.close()
    it 'should ...', ->
      co ->
        KEY = 'FACADE_TEST_HTTP_COLLECTION_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @Module: Test
          @attribute test: String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::HttpCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @include LeanRC::HttpCollectionMixin
          @Module: Test
          @public delegate: RC::Class,
            default: Test::TestRecord
        Test::HttpCollection.initialize()
        facade.registerProxy Test::HttpCollection.new KEY
        collection = facade.retrieveProxy KEY
        assert.instanceOf collection, Test::HttpCollection
        data = yield RC::Utils.request 'GET', 'http://localhost:8000', json: yes
        console.log 'DATA:', data
        yield return
