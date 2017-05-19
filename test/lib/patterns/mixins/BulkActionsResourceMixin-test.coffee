{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
Resource = LeanRC::Resource
{ co } = LeanRC::Utils

describe 'BulkActionsResourceMixin', ->
  describe '#parseQuery', ->
    it 'should resource query', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::BulkActionsResourceMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        resource.beforeActionHook
          queryParams: query: '{"test":"test123"}'
        resource.parseQuery()
        assert.deepEqual resource.query, test: 'test123'
        yield return
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
          @include LeanRC::QueryableMixin
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
        { items, meta } = yield resource.list
          queryParams: query: '{}'
          pathParams: {}
          currentUserId: 'ID'
          headers: {}
          body: {}
        assert.deepEqual meta, pagination:
          total: 'not defined'
          limit: 'not defined'
          offset: 'not defined'
        assert.propertyVal items[0], 'test', 'test1'
        assert.propertyVal items[1], 'test', 'test2'
        yield return
  describe '#bulkUpdate', ->
    it 'should update resource multiple items', ->
      co ->
        KEY = 'TEST_RESOURCE_006'
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
              @type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::BulkActionsResourceMixin
          @module Test
          @public entityName: String, { default: 'TestEntity' }
        Test::TestResource.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @module Test
          @public parseQuery: Object,
            default: (aoQuery) ->
              voQuery = _.mapKeys aoQuery, (value, key) -> key.replace /^@doc\./, ''
              voQuery = _.mapValues voQuery, (value, key) ->
                if value['$eq']? then value['$eq'] else value
              $filter: voQuery
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
          @public @async patch: Function,
            default: (id, aoRecord) ->
              item = _.find @getData().data, {id}
              if item?
                FORBIDDEN = [ '_key', 'id', '_type', '_rev' ]
                snapshot = _.omit (aoRecord.toJSON?() ? aoRecord ? {}), FORBIDDEN
                item[key] = value  for own key, value of snapshot
              yield @take id
          @public @async take: Function,
            default: (id) ->
              result = []
              if (data = _.find @getData().data, {id})?
                result.push data
              cursor = LeanRC::Cursor.new @, result
              yield cursor.first()
        Test::Collection.initialize()
        facade = LeanRC::Facade.getInstance KEY
        COLLECTION_NAME = 'TestEntitiesCollection'
        facade.registerProxy Test::Collection.new COLLECTION_NAME,
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
          data: []
        collection = facade.retrieveProxy COLLECTION_NAME
        resource = Test::TestResource.new()
        resource.initializeNotifier KEY
        record1 = yield resource.create body: test_entity: test: 'test1'
        record2 = yield resource.create body: test_entity: test: 'test2'
        record3 = yield resource.create body: test_entity: test: 'test2'
        yield resource.bulkUpdate
          queryParams: query: '{"test":{"$eq":"test2"}}'
          body: test_entity: test: 'test8'
        { items } = yield resource.list queryParams: query: '{"test":{"$eq":"test8"}}'
        assert.lengthOf items, 2
        for record in items
          assert.propertyVal record, 'test', 'test8'
        yield return
  describe '#bulkPatch', ->
    it 'should update resource multiple items', ->
      co ->
        KEY = 'TEST_RESOURCE_006'
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
              @type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::BulkActionsResourceMixin
          @module Test
          @public entityName: String, { default: 'TestEntity' }
        Test::TestResource.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @module Test
          @public parseQuery: Object,
            default: (aoQuery) ->
              voQuery = _.mapKeys aoQuery, (value, key) -> key.replace /^@doc\./, ''
              voQuery = _.mapValues voQuery, (value, key) ->
                if value['$eq']? then value['$eq'] else value
              $filter: voQuery
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
          @public @async patch: Function,
            default: (id, aoRecord) ->
              item = _.find @getData().data, {id}
              if item?
                FORBIDDEN = [ '_key', 'id', '_type', '_rev' ]
                snapshot = _.omit (aoRecord.toJSON?() ? aoRecord ? {}), FORBIDDEN
                item[key] = value  for own key, value of snapshot
              yield @take id
          @public @async take: Function,
            default: (id) ->
              result = []
              if (data = _.find @getData().data, {id})?
                result.push data
              cursor = LeanRC::Cursor.new @, result
              yield cursor.first()
        Test::Collection.initialize()
        facade = LeanRC::Facade.getInstance KEY
        COLLECTION_NAME = 'TestEntitiesCollection'
        facade.registerProxy Test::Collection.new COLLECTION_NAME,
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
          data: []
        collection = facade.retrieveProxy COLLECTION_NAME
        resource = Test::TestResource.new()
        resource.initializeNotifier KEY
        record1 = yield resource.create body: test_entity: test: 'test1'
        record2 = yield resource.create body: test_entity: test: 'test2'
        record3 = yield resource.create body: test_entity: test: 'test2'
        yield resource.bulkPatch
          queryParams: query: '{"test":{"$eq":"test2"}}'
          body: test_entity: test: 'test8'
        { items } = yield resource.list queryParams: query: '{"test":{"$eq":"test8"}}'
        assert.lengthOf items, 2
        for record in items
          assert.propertyVal record, 'test', 'test8'
        yield return
  describe '#bulkDelete', ->
    it 'should remove resource multiple items', ->
      co ->
        KEY = 'TEST_RESOURCE_007'
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
          @include LeanRC::BulkActionsResourceMixin
          @module Test
          @public entityName: String, { default: 'TestEntity' }
        Test::TestResource.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @module Test
          @public parseQuery: Object,
            default: (aoQuery) ->
              voQuery = _.mapKeys aoQuery, (value, key) -> key.replace /^@doc\./, ''
              voQuery = _.mapValues voQuery, (value, key) ->
                if value['$eq']? then value['$eq'] else value
              $filter: voQuery
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
          @public @async remove: Function,
            default: (id) ->
              _.remove @getData().data, {id}
              yield return yes
          @public @async take: Function,
            default: (id) ->
              result = []
              if (data = _.find @getData().data, {id})?
                result.push data
              cursor = LeanRC::Cursor.new @, result
              yield cursor.first()
        Test::Collection.initialize()
        facade = LeanRC::Facade.getInstance KEY
        COLLECTION_NAME = 'TestEntitiesCollection'
        facade.registerProxy Test::Collection.new COLLECTION_NAME,
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
          data: []
        collection = facade.retrieveProxy COLLECTION_NAME
        resource = Test::TestResource.new()
        resource.initializeNotifier KEY
        record1 = yield resource.create body: test_entity: test: 'test1'
        record2 = yield resource.create body: test_entity: test: 'test2'
        record3 = yield resource.create body: test_entity: test: 'test2'
        assert.lengthOf collection.getData().data, 3
        assert.lengthOf _.filter(collection.getData().data, test: 'test2'), 2
        yield resource.bulkDelete
          queryParams: query: '{"test":{"$eq":"test2"}}'

        assert.lengthOf collection.getData().data, 1
        assert.lengthOf _.filter(collection.getData().data, test: 'test2'), 0
        yield return
