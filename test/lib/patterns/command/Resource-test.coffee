EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
httpErrors = require 'http-errors'
LeanRC = require.main.require 'lib'
Resource = LeanRC::Resource
{ co } = LeanRC::Utils

describe 'Resource', ->
  describe '.new', ->
    it 'should create new command', ->
      expect ->
        resource = Resource.new()
      .to.not.throw Error
  describe '#keyName', ->
    it 'should get key name using entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        { keyName } = resource
        assert.equal keyName, 'test_entity'
        yield return
  describe '#itemEntityName', ->
    it 'should get item name using entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        { itemEntityName } = resource
        assert.equal itemEntityName, 'test_entity'
        yield return
  describe '#listEntityName', ->
    it 'should get list name using entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        { listEntityName } = resource
        assert.equal listEntityName, 'test_entities'
        yield return
  describe '#collectionName', ->
    it 'should get collection name using entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        { collectionName } = resource
        assert.equal collectionName, 'TestEntitiesCollection'
        yield return
  describe '#collection', ->
    it 'should get collection', ->
      co ->
        TEST_FACADE = 'TEST_FACADE_001'
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        facade = LeanRC::Facade.getInstance TEST_FACADE
        resource = Test::TestResource.new()
        resource.initializeNotifier TEST_FACADE
        { collectionName } = resource
        boundCollection = LeanRC::Collection.new collectionName
        facade.registerProxy boundCollection
        { collection } = resource
        assert.equal collection, boundCollection
        facade.remove()
        yield return
  describe '#action', ->
    it 'should create actions', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @action test1: String,
            default: 'test1'
          @action test2: String,
            default: 'test2'
          @action test3: String,
            default: 'test3'
        Test::TestResource.initialize()
        assert.deepEqual Test::TestResource.metaObject.data.actions.test1,
          default: 'test1'
          attr: 'test1'
          attrType: String
          level: LeanRC::PUBLIC
          pointer: 'test1'
        assert.deepEqual Test::TestResource.metaObject.data.actions.test2,
          default: 'test2'
          attr: 'test2'
          attrType: String
          level: LeanRC::PUBLIC
          pointer: 'test2'
        assert.deepEqual Test::TestResource.metaObject.data.actions.test3,
          default: 'test3'
          attr: 'test3'
          attrType: String
          level: LeanRC::PUBLIC
          pointer: 'test3'
        yield return
  describe '#actions', ->
    it 'should get resource actions', ->
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
          @action test1: String,
            default: 'test1'
          @action test2: String,
            default: 'test2'
          @action test3: String,
            default: 'test3'
        Test::TestResource.initialize()
        assert.deepEqual Test::TestResource.actions.test1,
          default: 'test1'
          attr: 'test1'
          attrType: String
          level: LeanRC::PUBLIC
          pointer: 'test1'
        assert.deepEqual Test::TestResource.actions.test2,
          default: 'test2'
          attr: 'test2'
          attrType: String
          level: LeanRC::PUBLIC
          pointer: 'test2'
        assert.deepEqual Test::TestResource.actions.test3,
          default: 'test3'
          attr: 'test3'
          attrType: String
          level: LeanRC::PUBLIC
          pointer: 'test3'
        { actions } = Test::TestResource
        assert.propertyVal actions.list, 'attr', 'list'
        assert.propertyVal actions.list, 'attrType', Function
        assert.propertyVal actions.list, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.list, 'async', LeanRC::ASYNC
        assert.propertyVal actions.detail, 'attr', 'detail'
        assert.propertyVal actions.detail, 'attrType', Function
        assert.propertyVal actions.detail, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.detail, 'async', LeanRC::ASYNC
        assert.propertyVal actions.create, 'attr', 'create'
        assert.propertyVal actions.create, 'attrType', Function
        assert.propertyVal actions.create, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.create, 'async', LeanRC::ASYNC
        assert.propertyVal actions.update, 'attr', 'update'
        assert.propertyVal actions.update, 'attrType', Function
        assert.propertyVal actions.update, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.update, 'async', LeanRC::ASYNC
        assert.propertyVal actions.delete, 'attr', 'delete'
        assert.propertyVal actions.delete, 'attrType', Function
        assert.propertyVal actions.delete, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.delete, 'async', LeanRC::ASYNC
        assert.propertyVal actions.bulkUpdate, 'attr', 'bulkUpdate'
        assert.propertyVal actions.bulkUpdate, 'attrType', Function
        assert.propertyVal actions.bulkUpdate, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.bulkUpdate, 'async', LeanRC::ASYNC
        assert.propertyVal actions.bulkPatch, 'attr', 'bulkPatch'
        assert.propertyVal actions.bulkPatch, 'attrType', Function
        assert.propertyVal actions.bulkPatch, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.bulkPatch, 'async', LeanRC::ASYNC
        assert.propertyVal actions.bulkDelete, 'attr', 'bulkDelete'
        assert.propertyVal actions.bulkDelete, 'attrType', Function
        assert.propertyVal actions.bulkDelete, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.bulkDelete, 'async', LeanRC::ASYNC
        yield return
  describe '#beforeActionHook', ->
    it 'should parse action params as arguments', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        resource.beforeActionHook
          query: query: '{"test":"test123"}'
          pathParams: testParam: 'testParamValue'
          headers: 'test-header': 'test-header-value'
          request: body: test: 'test678'
        assert.deepPropertyVal resource, 'context.query.query', '{"test":"test123"}'
        assert.deepPropertyVal resource, 'context.pathParams.testParam', 'testParamValue'
        assert.deepPropertyVal resource, 'context.headers.test-header', 'test-header-value'
        assert.deepPropertyVal resource, 'context.request.body.test', 'test678'
        yield return
  describe '#getQuery', ->
    it 'should get resource query', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        resource.context =
          query: query: '{"test":"test123"}'
        resource.getQuery()
        assert.deepEqual resource.query, test: 'test123'
        yield return
  describe '#getRecordId', ->
    it 'should get resource record ID', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        resource.context =
          pathParams: test_entity: 'ID123456'
        resource.getRecordId()
        assert.propertyVal resource, 'recordId', 'ID123456'
        yield return
  describe '#getRecordBody', ->
    it 'should get body', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        TestResource.initialize()
        resource = TestResource.new()
        resource.context =
          request: body: test_entity: test: 'test9'
        resource.getRecordBody()
        assert.deepEqual resource.recordBody, test: 'test9'
        yield return
  describe '#omitBody', ->
    it 'should clean body from unneeded properties', ->
      co ->
        TEST_FACADE = 'TEST_FACADE_002'
        facade = LeanRC::Facade.getInstance TEST_FACADE
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        TestResource.initialize()
        class TestEntity extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestEntity
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'Test::TestEntity'
        TestEntity.initialize()
        resource = TestResource.new()
        resource.initializeNotifier TEST_FACADE
        { collectionName } = resource
        boundCollection = LeanRC::Collection.new collectionName,
          delegate: TestEntity
        facade.registerProxy boundCollection
        resource.context =
          request: body: test_entity:
            _id: '123', test: 'test9', _space: 'test', type: 'TestEntity'
        resource.getRecordBody()
        resource.omitBody()
        assert.deepEqual resource.recordBody, test: 'test9', type: 'Test::TestEntity'
        facade.remove()
        yield return
  describe '#beforeUpdate', ->
    it 'should get body with ID', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        resource.context =
          pathParams: test_entity: 'ID123456'
          request: body: test_entity: test: 'test9'
        resource.getRecordId()
        resource.getRecordBody()
        resource.beforeUpdate()
        assert.deepEqual resource.recordBody, id: 'ID123456', test: 'test9'
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
              @type = 'Test::TestRecord'
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
        { items, meta } = yield resource.list query: query: '{}'
        assert.deepEqual meta, pagination:
          total: 'not defined'
          limit: 'not defined'
          offset: 'not defined'
        assert.propertyVal items[0], 'test', 'test1'
        assert.propertyVal items[1], 'test', 'test2'
        facade.remove()
        yield return
  describe '#detail', ->
    it 'should get resource single item', ->
      co ->
        KEY = 'TEST_RESOURCE_002'
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
          @module Test
          @public entityName: String, { default: 'TestEntity' }
        Test::TestResource.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @module Test
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
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
        yield collection.create test: 'test1'
        record = yield collection.create test: 'test2'
        resource = Test::TestResource.new()
        resource.initializeNotifier KEY
        context =
          pathParams: "#{resource.keyName}": record.id
        result = yield resource.detail context
        assert.propertyVal result, 'id', record.id
        assert.propertyVal result, 'test', 'test2'
        facade.remove()
        yield return
  describe '#create', ->
    it 'should create resource single item', ->
      co ->
        KEY = 'TEST_RESOURCE_003'
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
          @module Test
          @public entityName: String, { default: 'TestEntity' }
        Test::TestResource.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @module Test
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
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
        result = yield resource.create request: body: test_entity: test: 'test3'
        assert.propertyVal result, 'test', 'test3'
        facade.remove()
        yield return
  describe '#update', ->
    it 'should update resource single item', ->
      co ->
        KEY = 'TEST_RESOURCE_004'
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
          @module Test
          @public entityName: String, { default: 'TestEntity' }
        Test::TestResource.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @module Test
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
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
                FORBIDDEN = [ '_key', '_id', '_type', '_rev' ]
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
        record = yield collection.create test: 'test3'
        result = yield resource.update
          pathParams: test_entity: record.id
          request: body: test_entity: test: 'test8'
        assert.propertyVal result, 'test', 'test8'
        facade.remove()
        yield return
  describe '#delete', ->
    it 'should remove resource single item', ->
      co ->
        KEY = 'TEST_RESOURCE_005'
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
          @module Test
          @public entityName: String, { default: 'TestEntity' }
        Test::TestResource.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableMixin
          @module Test
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
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
                FORBIDDEN = [ '_key', '_id', '_type', '_rev' ]
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
        record = yield collection.create test: 'test3'
        result = yield resource.delete
          pathParams: test_entity: record.id
        assert.propertyVal result, 'isHidden', yes
        facade.remove()
        yield return
  describe '#execute', ->
    it 'should call execution', ->
      co ->
        KEY = 'TEST_RESOURCE_008'
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
        yield collection.create test: 'test1'
        yield collection.create test: 'test2'
        yield collection.create test: 'test2'
        # yield resource.create body: test_entity: test: 'test1'
        # yield resource.create body: test_entity: test: 'test2'
        # yield resource.create body: test_entity: test: 'test2'
        spySendNotitfication = sinon.spy resource, 'sendNotification'
        testBody =
          context: query: query: '{"test":{"$eq":"test2"}}'
          reverse: 'TEST_REVERSE'
        notification = LeanRC::Notification.new 'TEST_NAME', testBody, 'list'
        yield resource.execute notification
        [ name, body, type ] = spySendNotitfication.args[0]
        assert.equal name, LeanRC::HANDLER_RESULT
        {result, resource:voResource} = body
        { meta, items } = result
        assert.deepEqual meta, pagination:
          total: 'not defined'
          limit: 'not defined'
          offset: 'not defined'
        assert.deepEqual voResource, resource
        assert.lengthOf items, 2
        assert.equal type, 'TEST_REVERSE'
        facade.remove()
        yield return
  describe '#checkApiVersion', ->
    it 'should check API version', ->
      co ->
        KEY = 'TEST_RESOURCE_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @action test: Function,
            default: ->
        Test::TestResource.initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        req =
          method: 'GET'
          url: 'http://localhost:8888/v/v2.0/test_entity/ID123456'
          headers: 'x-forwarded-for': '192.168.0.1'
        res = new MyResponse
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
        TestSwitch.initialize()
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        resource = Test::TestResource.new()
        resource.initializeNotifier KEY
        resource.context = Test::Context.new req, res, switchMediator
        try
          resource.context.pathParams =
            v: 'v1.0'
            test_entity: 'ID123456'
          yield resource.checkApiVersion()
        catch e
        assert.isDefined e
        try
          resource.context.pathParams =
            v: 'v2.0'
            test_entity: 'ID123456'
          yield resource.checkApiVersion()
        catch e
          assert.isDefined e
        facade.remove()
        yield return
  describe '#setOwnerId', ->
    it 'should get owner ID for body', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        resource.currentUser = id: 'ID123'
        resource.context =
          pathParams: test_entity: 'ID123456'
          request: body: test_entity: test: 'test9'
        resource.getRecordId()
        resource.getRecordBody()
        resource.beforeUpdate()
        yield resource.setOwnerId()
        assert.deepEqual resource.recordBody,
          test: 'test9'
          id: 'ID123456'
          ownerId: 'ID123'
        yield return
  describe '#protectOwnerId', ->
    it 'should omit owner ID from body', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        resource.currentUser = id: 'ID123'
        resource.context =
          pathParams: test_entity: 'ID123456'
          request: body: test_entity: test: 'test9'
        resource.getRecordId()
        resource.getRecordBody()
        resource.beforeUpdate()
        yield resource.setOwnerId()
        assert.deepEqual resource.recordBody,
          test: 'test9'
          id: 'ID123456'
          ownerId: 'ID123'
        yield resource.protectOwnerId()
        assert.deepEqual resource.recordBody,
          test: 'test9'
          id: 'ID123456'
        yield return
  describe '#setSpaceId', ->
    it 'should set space ID for body', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        resource.currentUser = id: 'ID123'
        resource.context =
          pathParams: test_entity: 'ID123456', space: 'SPACE123'
          request: body: test_entity: test: 'test9'
        resource.getRecordId()
        resource.getRecordBody()
        resource.beforeUpdate()
        yield resource.setSpaceId()
        assert.deepEqual resource.recordBody,
          test: 'test9'
          id: 'ID123456'
          spaceId: 'SPACE123'
        yield return
  describe '#protectSpaceId', ->
    it 'should omit space ID from body', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        resource.currentUser = id: 'ID123'
        resource.context =
          pathParams: test_entity: 'ID123456', space: 'SPACE123'
          request: body: test_entity: test: 'test9'
        resource.getRecordId()
        resource.getRecordBody()
        resource.beforeUpdate()
        yield resource.setSpaceId()
        assert.deepEqual resource.recordBody,
          test: 'test9'
          id: 'ID123456'
          spaceId: 'SPACE123'
        yield resource.protectSpaceId()
        assert.deepEqual resource.recordBody,
          test: 'test9'
          id: 'ID123456'
        yield return
  describe '#beforeLimitedList', ->
    it 'should update query if caller user is not admin', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
        resource.currentUser = id: 'ID123', isAdmin: no
        resource.context =
          pathParams: test_entity: 'ID123456', space: 'SPACE123'
          request: body: test_entity: test: 'test9'
        resource.getRecordId()
        resource.getRecordBody()
        resource.beforeUpdate()
        yield resource.beforeLimitedList()
        assert.deepEqual resource.query, ownerId: 'ID123'
        yield return
  describe '#checkOwner', ->
    it 'should check if user is resource owner', ->
      co ->
        KEY = 'TEST_RESOURCE_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        TestResource.initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        class MyResponse extends EventEmitter
          _headers: {}
          getHeaders: -> LeanRC::Utils.copy @_headers
          getHeader: (field) -> @_headers[field.toLowerCase()]
          setHeader: (field, value) -> @_headers[field.toLowerCase()] = value
          removeHeader: (field) -> delete @_headers[field.toLowerCase()]
          end: (data, encoding = 'utf-8', callback = ->) ->
            @finished = yes
            @emit 'finish', data?.toString? encoding
            callback()
          constructor: (args...) ->
            super args...
            { @finished, @_headers } = finished: no, _headers: {}
        req =
          method: 'GET'
          url: 'http://localhost:8888/space/SPACE123/test_entity/ID123456'
          headers: 'x-forwarded-for': '192.168.0.1'
        res = new MyResponse
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
        TestSwitch.initialize()
        class TestEntity extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute ownerId: String
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestEntity
          @public init: Function,
            default: ->
              @super arguments...
              @type = 'Test::TestEntity'
        TestEntity.initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        TestCollection.initialize()
        resource = TestResource.new()
        resource.initializeNotifier KEY
        { collectionName } = resource
        boundCollection = TestCollection.new collectionName,
          delegate: TestEntity
        facade.registerProxy boundCollection
        yield boundCollection.create id: 'ID123456', test: 'test', ownerId: 'ID124'
        yield boundCollection.create id: 'ID123457', test: 'test', ownerId: 'ID123'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        resource = Test::TestResource.new()
        resource.initializeNotifier KEY
        resource.currentUser = id: 'ID123', isAdmin: no
        resource.context = Test::Context.new req, res, switchMediator
        resource.context.pathParams = test_entity: 'ID123455', space: 'SPACE123'
        resource.context.request = body: test_entity: test: 'test9'
        resource.getRecordId()
        resource.getRecordBody()
        resource.beforeUpdate()
        try
          yield resource.checkOwner()
        catch e
        assert.instanceOf e, httpErrors.Unauthorized
        resource.session = uid: '123456789'
        try
          yield resource.checkOwner()
        catch e
        assert.instanceOf e, httpErrors.NotFound
        resource.context.pathParams.test_entity = 'ID123456'
        try
          yield resource.checkOwner()
        catch e
        assert.instanceOf e, httpErrors.Forbidden
        resource.context.pathParams.test_entity = 'ID123457'
        yield resource.checkOwner()
        facade.remove()
        yield return
