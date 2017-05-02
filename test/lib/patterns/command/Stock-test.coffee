{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
Stock = LeanRC::Stock
{ co } = LeanRC::Utils

describe 'Stock', ->
  describe '.new', ->
    it 'should create new command', ->
      expect ->
        stock = Stock.new()
      .to.not.throw Error
  describe '#keyName', ->
    it 'should get key name using entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        stock = Test::TestStock.new()
        { keyName } = stock
        assert.equal keyName, 'test_entity'
        yield return
  describe '#itemEntityName', ->
    it 'should get item name using entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        stock = Test::TestStock.new()
        { itemEntityName } = stock
        assert.equal itemEntityName, 'test_entity'
        yield return
  describe '#listEntityName', ->
    it 'should get list name using entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        stock = Test::TestStock.new()
        { listEntityName } = stock
        assert.equal listEntityName, 'test_entities'
        yield return
  describe '#collectionName', ->
    it 'should get collection name using entity name', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        stock = Test::TestStock.new()
        { collectionName } = stock
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
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        facade = LeanRC::Facade.getInstance TEST_FACADE
        stock = Test::TestStock.new()
        stock.initializeNotifier TEST_FACADE
        { collectionName } = stock
        boundCollection = LeanRC::Collection.new collectionName
        facade.registerProxy boundCollection
        { collection } = stock
        assert.equal collection, boundCollection
        yield return
  describe '#action', ->
    it 'should create actions', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
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
        Test::TestStock.initialize()
        assert.deepEqual Test::TestStock.metaObject.data.actions.test1,
          default: 'test1'
          attr: 'test1'
          attrType: String
          level: LeanRC::PUBLIC
        assert.deepEqual Test::TestStock.metaObject.data.actions.test2,
          default: 'test2'
          attr: 'test2'
          attrType: String
          level: LeanRC::PUBLIC
        assert.deepEqual Test::TestStock.metaObject.data.actions.test3,
          default: 'test3'
          attr: 'test3'
          attrType: String
          level: LeanRC::PUBLIC
        yield return
  describe '#actions', ->
    it 'should get stock actions', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
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
        Test::TestStock.initialize()
        assert.deepEqual Test::TestStock.actions.test1,
          default: 'test1'
          attr: 'test1'
          attrType: String
          level: LeanRC::PUBLIC
        assert.deepEqual Test::TestStock.actions.test2,
          default: 'test2'
          attr: 'test2'
          attrType: String
          level: LeanRC::PUBLIC
        assert.deepEqual Test::TestStock.actions.test3,
          default: 'test3'
          attr: 'test3'
          attrType: String
          level: LeanRC::PUBLIC
        { actions } = Test::TestStock
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
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        stock = Test::TestStock.new()
        stock.beforeActionHook
          queryParams: query: '{"test":"test123"}'
          pathParams: testParam: 'testParamValue'
          currentUserId: 'ID'
          headers: 'test-header': 'test-header-value'
          body: test: 'test678'
        assert.deepPropertyVal stock, 'queryParams.query', '{"test":"test123"}'
        assert.deepPropertyVal stock, 'pathParams.testParam', 'testParamValue'
        assert.propertyVal stock, 'currentUserId', 'ID'
        assert.deepPropertyVal stock, 'headers.test-header', 'test-header-value'
        assert.deepPropertyVal stock, 'body.test', 'test678'
        yield return
  describe '#parseQuery', ->
    it 'should stock query', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        stock = Test::TestStock.new()
        stock.beforeActionHook
          queryParams: query: '{"test":"test123"}'
        stock.parseQuery()
        assert.deepEqual stock.query, test: 'test123'
        yield return
  describe '#parsePathParams', ->
    it 'should get stock record ID', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        stock = Test::TestStock.new()
        stock.beforeActionHook
          pathParams: test_entity: 'ID123456'
        stock.parsePathParams()
        assert.propertyVal stock, 'recordId', 'ID123456'
        yield return
  describe '#parseBody', ->
    it 'should get body', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        stock = Test::TestStock.new()
        stock.beforeActionHook
          body: test_entity: test: 'test9'
        stock.parseBody()
        assert.deepEqual stock.recordBody, test: 'test9'
        yield return
  describe '#beforeUpdate', ->
    it 'should get body with ID', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        stock = Test::TestStock.new()
        stock.beforeActionHook
          pathParams: test_entity: 'ID123456'
          body: test_entity: test: 'test9'
        stock.parsePathParams()
        stock.parseBody()
        stock.beforeUpdate()
        assert.deepEqual stock.recordBody, id: 'ID123456', test: 'test9'
        yield return
  describe '#list', ->
    it 'should list of stock items', ->
      co ->
        KEY = 'TEST_STOCK_001'
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestStock.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @include LeanRC::QueryableMixin
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: Function,
            default: (aoParsedQuery) ->
              data = _.filter @getData().data, aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async push: Function,
            default: (aoRecord) ->
              isExist = (id) => (_.find @getData().data, _key: id)?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord._key = key
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
        stock = Test::TestStock.new()
        stock.initializeNotifier KEY
        hooks = Test::TestStock.metaObject.getGroup 'hooks'
        { items, meta } = yield stock.list
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
    it 'should get stock single item', ->
      co ->
        KEY = 'TEST_STOCK_002'
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String, { default: 'TestEntity' }
        Test::TestStock.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @include LeanRC::QueryableMixin
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: Function,
            default: (aoParsedQuery) ->
              data = _.filter @getData().data, aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async push: Function,
            default: (aoRecord) ->
              isExist = (id) => (_.find @getData().data, _key: id)?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord._key = key
              @getData().data.push aoRecord.toJSON()
              yield yes
          @public @async take: Function,
            default: (id) ->
              result = []
              if (data = _.find @getData().data, _key: id)?
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
        stock = Test::TestStock.new()
        stock.initializeNotifier KEY
        hooks = Test::TestStock.metaObject.getGroup 'hooks'
        params =
          queryParams: {}
          pathParams: "#{stock.keyName}": record.id
          currentUserId: 'ID'
          headers: {}
          body: {}
        result = yield stock.detail params
        assert.propertyVal result, 'id', record.id
        assert.propertyVal result, 'test', 'test2'
        yield return
  describe '#create', ->
    it 'should create stock single item', ->
      co ->
        KEY = 'TEST_STOCK_003'
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String, { default: 'TestEntity' }
        Test::TestStock.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @include LeanRC::QueryableMixin
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: Function,
            default: (aoParsedQuery) ->
              data = _.filter @getData().data, aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async push: Function,
            default: (aoRecord) ->
              isExist = (id) => (_.find @getData().data, _key: id)?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord._key = key
              @getData().data.push aoRecord.toJSON()
              yield yes
          @public @async take: Function,
            default: (id) ->
              result = []
              if (data = _.find @getData().data, _key: id)?
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
        stock = Test::TestStock.new()
        stock.initializeNotifier KEY
        hooks = Test::TestStock.metaObject.getGroup 'hooks'
        result = yield stock.create body: test_entity: test: 'test3'
        assert.propertyVal result, 'test', 'test3'
        yield return
  describe '#update', ->
    it 'should update stock single item', ->
      co ->
        KEY = 'TEST_STOCK_004'
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String, { default: 'TestEntity' }
        Test::TestStock.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @include LeanRC::QueryableMixin
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: Function,
            default: (aoParsedQuery) ->
              data = _.filter @getData().data, aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async push: Function,
            default: (aoRecord) ->
              isExist = (id) => (_.find @getData().data, _key: id)?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord._key = key
              @getData().data.push aoRecord.toJSON()
              yield yes
          @public @async patch: Function,
            default: (id, aoRecord) ->
              { '@doc._key': { '$eq': id } } = id
              item = _.find @getData().data, _key: id
              if item?
                FORBIDDEN = [ '_key', 'id', '_type', '_rev' ]
                snapshot = _.omit (aoRecord.toJSON?() ? aoRecord ? {}), FORBIDDEN
                item[key] = value  for own key, value of snapshot
              yield @take id
          @public @async take: Function,
            default: (id) ->
              result = []
              if (data = _.find @getData().data, _key: id)?
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
        stock = Test::TestStock.new()
        stock.initializeNotifier KEY
        hooks = Test::TestStock.metaObject.getGroup 'hooks'
        record = yield stock.create body: test_entity: test: 'test3'
        result = yield stock.update
          pathParams: test_entity: record.id
          body: test_entity: test: 'test8'
        assert.propertyVal result, 'test', 'test8'
        yield return
  describe '#delete', ->
    it 'should remove stock single item', ->
      co ->
        KEY = 'TEST_STOCK_005'
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String, { default: 'TestEntity' }
        Test::TestStock.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @include LeanRC::QueryableMixin
          @public parseQuery: Object,
            default: (aoQuery) -> aoQuery
          @public @async executeQuery: Function,
            default: (aoParsedQuery) ->
              data = _.filter @getData().data, aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async push: Function,
            default: (aoRecord) ->
              isExist = (id) => (_.find @getData().data, _key: id)?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord._key = key
              @getData().data.push aoRecord.toJSON()
              yield yes
          @public @async patch: Function,
            default: (id, aoRecord) ->
              { '@doc._key': { '$eq': id } } = id
              item = _.find @getData().data, _key: id
              if item?
                FORBIDDEN = [ '_key', 'id', '_type', '_rev' ]
                snapshot = _.omit (aoRecord.toJSON?() ? aoRecord ? {}), FORBIDDEN
                item[key] = value  for own key, value of snapshot
              yield @take id
          @public @async take: Function,
            default: (id) ->
              result = []
              if (data = _.find @getData().data, _key: id)?
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
        stock = Test::TestStock.new()
        stock.initializeNotifier KEY
        hooks = Test::TestStock.metaObject.getGroup 'hooks'
        record = yield stock.create body: test_entity: test: 'test3'
        result = yield stock.delete
          pathParams: test_entity: record.id
        assert.propertyVal result, 'isHidden', yes
        yield return
  describe '#bulkUpdate', ->
    it 'should update stock multiple items', ->
      co ->
        KEY = 'TEST_STOCK_006'
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String, { default: 'TestEntity' }
        Test::TestStock.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @include LeanRC::QueryableMixin
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
              isExist = (id) => (_.find @getData().data, _key: id)?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord._key = key
              @getData().data.push aoRecord.toJSON()
              yield yes
          @public @async patch: Function,
            default: (id, aoRecord) ->
              { '@doc._key': { '$eq': id } } = id
              item = _.find @getData().data, _key: id
              if item?
                FORBIDDEN = [ '_key', 'id', '_type', '_rev' ]
                snapshot = _.omit (aoRecord.toJSON?() ? aoRecord ? {}), FORBIDDEN
                item[key] = value  for own key, value of snapshot
              yield @take id
          @public @async take: Function,
            default: (id) ->
              result = []
              if (data = _.find @getData().data, _key: id)?
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
        stock = Test::TestStock.new()
        stock.initializeNotifier KEY
        hooks = Test::TestStock.metaObject.getGroup 'hooks'
        record1 = yield stock.create body: test_entity: test: 'test1'
        record2 = yield stock.create body: test_entity: test: 'test2'
        record3 = yield stock.create body: test_entity: test: 'test2'
        yield stock.bulkUpdate
          queryParams: query: '{"test":{"$eq":"test2"}}'
          body: test_entity: test: 'test8'
        { items } = yield stock.list queryParams: query: '{"test":{"$eq":"test8"}}'
        assert.lengthOf items, 2
        for record in items
          assert.propertyVal record, 'test', 'test8'
        yield return
  describe '#bulkPatch', ->
    it 'should update stock multiple items', ->
      co ->
        KEY = 'TEST_STOCK_006'
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findModelByName: Function,
            default: (asType) -> Test::TestRecord
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::TestStock extends LeanRC::Stock
          @inheritProtected()
          @module Test
          @public entityName: String, { default: 'TestEntity' }
        Test::TestStock.initialize()
        class Test::Collection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @include LeanRC::QueryableMixin
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
              isExist = (id) => (_.find @getData().data, _key: id)?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord._key = key
              @getData().data.push aoRecord.toJSON()
              yield yes
          @public @async patch: Function,
            default: (id, aoRecord) ->
              { '@doc._key': { '$eq': id } } = id
              item = _.find @getData().data, _key: id
              if item?
                FORBIDDEN = [ '_key', 'id', '_type', '_rev' ]
                snapshot = _.omit (aoRecord.toJSON?() ? aoRecord ? {}), FORBIDDEN
                item[key] = value  for own key, value of snapshot
              yield @take id
          @public @async take: Function,
            default: (id) ->
              result = []
              if (data = _.find @getData().data, _key: id)?
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
        stock = Test::TestStock.new()
        stock.initializeNotifier KEY
        hooks = Test::TestStock.metaObject.getGroup 'hooks'
        record1 = yield stock.create body: test_entity: test: 'test1'
        record2 = yield stock.create body: test_entity: test: 'test2'
        record3 = yield stock.create body: test_entity: test: 'test2'
        yield stock.bulkPatch
          queryParams: query: '{"test":{"$eq":"test2"}}'
          body: test_entity: test: 'test8'
        { items } = yield stock.list queryParams: query: '{"test":{"$eq":"test8"}}'
        assert.lengthOf items, 2
        for record in items
          assert.propertyVal record, 'test', 'test8'
        yield return
  describe '#execute', ->
    ###
    it 'should create new stock', ->
      expect ->
        trigger = sinon.spy()
        trigger.reset()
        class TestStock extends Stock
          @inheritProtected()
          @public execute: Function,
            default: ->
              trigger()
        stock = TestStock.new()
        stock.execute()
        assert trigger.called
      .to.not.throw Error
    ###
