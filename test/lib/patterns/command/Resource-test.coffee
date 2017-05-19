{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
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
        assert.deepEqual Test::TestResource.metaObject.data.actions.test2,
          default: 'test2'
          attr: 'test2'
          attrType: String
          level: LeanRC::PUBLIC
        assert.deepEqual Test::TestResource.metaObject.data.actions.test3,
          default: 'test3'
          attr: 'test3'
          attrType: String
          level: LeanRC::PUBLIC
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
        assert.deepEqual Test::TestResource.actions.test2,
          default: 'test2'
          attr: 'test2'
          attrType: String
          level: LeanRC::PUBLIC
        assert.deepEqual Test::TestResource.actions.test3,
          default: 'test3'
          attr: 'test3'
          attrType: String
          level: LeanRC::PUBLIC
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
    it 'should parse action params as argumants', ->
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
          queryParams: query: '{"test":"test123"}'
          pathParams: testParam: 'testParamValue'
          currentUserId: 'ID'
          headers: 'test-header': 'test-header-value'
          body: test: 'test678'
        assert.deepPropertyVal resource, 'queryParams.query', '{"test":"test123"}'
        assert.deepPropertyVal resource, 'pathParams.testParam', 'testParamValue'
        assert.propertyVal resource, 'currentUserId', 'ID'
        assert.deepPropertyVal resource, 'headers.test-header', 'test-header-value'
        assert.deepPropertyVal resource, 'body.test', 'test678'
        yield return
  describe '#parsePathParams', ->
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
        resource.beforeActionHook
          pathParams: test_entity: 'ID123456'
        resource.parsePathParams()
        assert.propertyVal resource, 'recordId', 'ID123456'
        yield return
  describe '#parseBody', ->
    it 'should get body', ->
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
          body: test_entity: test: 'test9'
        resource.parseBody()
        assert.deepEqual resource.recordBody, test: 'test9'
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
        resource.beforeActionHook
          pathParams: test_entity: 'ID123456'
          body: test_entity: test: 'test9'
        resource.parsePathParams()
        resource.parseBody()
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
              @_type = 'Test::TestRecord'
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
        params =
          queryParams: {}
          pathParams: "#{resource.keyName}": record.id
          currentUserId: 'ID'
          headers: {}
          body: {}
        result = yield resource.detail params
        assert.propertyVal result, 'id', record.id
        assert.propertyVal result, 'test', 'test2'
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
              @_type = 'Test::TestRecord'
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
        result = yield resource.create body: test_entity: test: 'test3'
        assert.propertyVal result, 'test', 'test3'
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
              @_type = 'Test::TestRecord'
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
        record = yield resource.create body: test_entity: test: 'test3'
        result = yield resource.update
          pathParams: test_entity: record.id
          body: test_entity: test: 'test8'
        assert.propertyVal result, 'test', 'test8'
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
              @_type = 'Test::TestRecord'
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
        record = yield resource.create body: test_entity: test: 'test3'
        result = yield resource.delete
          pathParams: test_entity: record.id
        assert.propertyVal result, 'isHidden', yes
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
        yield resource.create body: test_entity: test: 'test1'
        yield resource.create body: test_entity: test: 'test2'
        yield resource.create body: test_entity: test: 'test2'
        spySendNotitfication = sinon.spy resource, 'sendNotification'
        testBody =
          queryParams: query: '{"test":{"$eq":"test2"}}'
          reverse: 'TEST_REVERSE'
        notification = LeanRC::Notification.new 'TEST_NAME', testBody, 'list'
        yield resource.execute notification
        [ name, body, type ] = spySendNotitfication.args[0]
        assert.equal name, LeanRC::HANDLER_RESULT
        { meta, items } = body
        assert.deepEqual meta, pagination:
          total: 'not defined'
          limit: 'not defined'
          offset: 'not defined'
        assert.lengthOf items, 2
        assert.equal type, 'TEST_REVERSE'
        yield return
