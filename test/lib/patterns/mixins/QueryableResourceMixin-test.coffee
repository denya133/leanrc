{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
Resource = LeanRC::Resource
{ co } = LeanRC::Utils

describe 'QueryableResourceMixin', ->
  describe '#list', ->
    it 'should list of resource items', ->
      co ->
        KEY = 'TEST_RESOURCE_001'
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async takeAll: Function,
            default: ->
              yield LeanRC::Cursor.new @, @getData().data
          @public @async executeQuery: Function,
            default: (aoParsedQuery) ->
              data = _.filter @getData().data, aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async push: Function,
            default: (aoRecord) ->
              isExist = (id) => (_.find @getData().data, {id})?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord.id = key
              @getData().data.push aoRecord.toJSON()
              yield yes
        Test::Collection.initialize()
        facade = LeanRC::Facade.getInstance KEY
        COLLECTION_NAME = 'TestEntitiesCollection'
        facade.registerProxy Test::Collection.new COLLECTION_NAME,
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
          data: []
        collection = facade.retrieveProxy COLLECTION_NAME
        yield collection.create test: 'test1'
        yield collection.create test: 'test2'
        resource = Test::TestResource.new()
        resource.initializeNotifier KEY
        { items, meta } = yield resource.list query: query: '{}'
        assert.deepEqual meta, pagination:
          total: 'not defined'
          limit: 'not defined'
          offset: 'not defined'
        assert.propertyVal items[0], 'test', 'test1'
        assert.propertyVal items[1], 'test', 'test2'
        facade.remove()
        yield return
