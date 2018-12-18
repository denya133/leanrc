EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
httpErrors = require 'http-errors'
LeanRC = require.main.require 'lib'
{
  AnyT, NilT
  FuncG, SubsetG, UnionG, ListG, StructG, MaybeG
  CollectionInterface, RecordInterface, QueryInterface, CursorInterface
  Resource
  Utils: { co }
} = LeanRC::

describe 'Resource', ->
  describe '.new', ->
    it 'should create new command', ->
      expect ->
        resource = Resource.new()
      .to.not.throw Error
  describe '#keyName', ->
    it 'should get key name using entity name', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
        { keyName } = resource
        assert.equal keyName, 'test_entity'
        yield return
  describe '#itemEntityName', ->
    it 'should get item name using entity name', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
        { itemEntityName } = resource
        assert.equal itemEntityName, 'test_entity'
        yield return
  describe '#listEntityName', ->
    it 'should get list name using entity name', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
        { listEntityName } = resource
        assert.equal listEntityName, 'test_entities'
        yield return
  describe '#collectionName', ->
    it 'should get collection name using entity name', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
        { collectionName } = resource
        assert.equal collectionName, 'TestEntitiesCollection'
        yield return
  describe '#collection', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get collection', ->
      co ->
        TEST_FACADE = 'TEST_FACADE_001'
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        facade = LeanRC::Facade.getInstance TEST_FACADE
        resource = TestResource.new()
        resource.initializeNotifier TEST_FACADE
        { collectionName } = resource
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
          @initialize()
        class TestEntityRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> TestEntityRecord
          @public init: FuncG([Object, CollectionInterface], NilT),
            default: ->
              @super arguments...
              @type = 'Test::TestEntityRecord'
              return
          @initialize()
        boundCollection = TestsCollection.new collectionName,
          delegate: 'TestEntityRecord'
        facade.registerProxy boundCollection
        { collection } = resource
        assert.equal collection, boundCollection
        yield return
  describe '#action', ->
    it 'should create actions', ->
      co ->
        default1 = -> yield return 'test1'
        default2 = -> yield return 'test2'
        default3 = -> yield return 'test3'
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @action @async test1: Function,
            default: default1
          @action @async test2: Function,
            default: default2
          @action @async test3: Function,
            default: default3
          @initialize()
        {
          test1
          test2
          test3
        } = TestResource.metaObject.data.actions
        assert.equal test1.default, default1
        assert.equal test1.attr, 'test1'
        assert.equal test1.attrType, LeanRC::FunctionT
        assert.equal test1.level, LeanRC::PUBLIC
        assert.equal test1.async, LeanRC::ASYNC
        assert.equal test1.pointer, 'test1'

        assert.equal test2.default, default2
        assert.equal test2.attr, 'test2'
        assert.equal test2.attrType, LeanRC::FunctionT
        assert.equal test2.level, LeanRC::PUBLIC
        assert.equal test2.async, LeanRC::ASYNC
        assert.equal test2.pointer, 'test2'

        assert.equal test3.default, default3
        assert.equal test3.attr, 'test3'
        assert.equal test3.attrType, LeanRC::FunctionT
        assert.equal test3.level, LeanRC::PUBLIC
        assert.equal test3.async, LeanRC::ASYNC
        assert.equal test3.pointer, 'test3'
        yield return
  describe '#actions', ->
    it 'should get resource actions', ->
      co ->
        default1 = -> yield return 'test1'
        default2 = -> yield return 'test2'
        default3 = -> yield return 'test3'
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::QueryableResourceMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @action @async test1: Function,
            default: default1
          @action @async test2: Function,
            default: default2
          @action @async test3: Function,
            default: default3
          @initialize()
        {
          test1
          test2
          test3
        } = TestResource.actions
        assert.equal test1.default, default1
        assert.equal test1.attr, 'test1'
        assert.equal test1.attrType, LeanRC::FunctionT
        assert.equal test1.level, LeanRC::PUBLIC
        assert.equal test1.async, LeanRC::ASYNC
        assert.equal test1.pointer, 'test1'

        assert.equal test2.default, default2
        assert.equal test2.attr, 'test2'
        assert.equal test2.attrType, LeanRC::FunctionT
        assert.equal test2.level, LeanRC::PUBLIC
        assert.equal test2.async, LeanRC::ASYNC
        assert.equal test2.pointer, 'test2'

        assert.equal test3.default, default3
        assert.equal test3.attr, 'test3'
        assert.equal test3.attrType, LeanRC::FunctionT
        assert.equal test3.level, LeanRC::PUBLIC
        assert.equal test3.async, LeanRC::ASYNC
        assert.equal test3.pointer, 'test3'
        { actions } = TestResource
        assert.propertyVal actions.list, 'attr', 'list'
        assert.propertyVal actions.list, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.list, 'async', LeanRC::ASYNC
        assert.propertyVal actions.detail, 'attr', 'detail'
        assert.propertyVal actions.detail, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.detail, 'async', LeanRC::ASYNC
        assert.propertyVal actions.create, 'attr', 'create'
        assert.propertyVal actions.create, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.create, 'async', LeanRC::ASYNC
        assert.propertyVal actions.update, 'attr', 'update'
        assert.propertyVal actions.update, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.update, 'async', LeanRC::ASYNC
        assert.propertyVal actions.delete, 'attr', 'delete'
        assert.propertyVal actions.delete, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.delete, 'async', LeanRC::ASYNC
        ### Moved to -> ModellingResourceMixin
        assert.propertyVal actions.query, 'attr', 'query'
        assert.propertyVal actions.query, 'attrType', Function
        assert.propertyVal actions.query, 'level', LeanRC::PUBLIC
        assert.propertyVal actions.query, 'async', LeanRC::ASYNC
        ###
        yield return
  describe '#beforeActionHook', ->
    it 'should parse action params as arguments', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
        Reflect.defineProperty resource, 'context',
          writable: yes
          value: undefined
        ctx = Symbol 'ctx'
        # resource.beforeActionHook.body.call resource, ctx
        resource.beforeActionHook ctx
        assert.strictEqual resource.context, ctx, 'beforeActionHook called with context and set it in resource.context'
        yield return
  describe '#getQuery', ->
    it 'should get resource query', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
        Reflect.defineProperty resource, 'listQuery',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'context',
          writable: yes
          value: query: query: '{"test":"test123"}'
        # resource.context =
        #   query: query: '{"test":"test123"}'
        resource.getQuery()
        assert.deepEqual resource.listQuery, test: 'test123'
        yield return
  describe '#getRecordId', ->
    it 'should get resource record ID', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
        Reflect.defineProperty resource, 'recordId',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'context',
          writable: yes
          value: pathParams: test_entity: 'ID123456'
        # resource.context =
        #   pathParams: test_entity: 'ID123456'
        resource.getRecordId()
        assert.deepEqual resource.recordId, 'ID123456'
        # assert.propertyVal resource, 'recordId', 'ID123456'
        yield return
  describe '#getRecordBody', ->
    it 'should get body', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        TestResource.initialize()
        resource = TestResource.new()
        Reflect.defineProperty resource, 'recordBody',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'context',
          writable: yes
          value: request: body: test_entity: test: 'test9'
        # resource.context =
        #   request: body: test_entity: test: 'test9'
        resource.getRecordBody()
        assert.deepEqual resource.recordBody, test: 'test9'
        yield return
  describe '#omitBody', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should clean body from unneeded properties', ->
      co ->
        TEST_FACADE = 'TEST_FACADE_002'
        facade = LeanRC::Facade.getInstance TEST_FACADE
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @module Test
          @initialize()
        class TestEntityRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> TestEntityRecord
          # @public init: FuncG([Object, CollectionInterface], NilT),
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestEntityRecord'
          #     return
          @initialize()
        resource = TestResource.new()
        resource.initializeNotifier TEST_FACADE
        { collectionName } = resource
        boundCollection = TestsCollection.new collectionName,
          delegate: 'TestEntityRecord'
        facade.registerProxy boundCollection
        Reflect.defineProperty resource, 'recordBody',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'context',
          writable: yes
          value: request: body: test_entity:
            _id: '123', test: 'test9', _space: 'test', type: 'TestEntityRecord'

        # resource.context =
        #   request: body: test_entity:
        #     _id: '123', test: 'test9', _space: 'test', type: 'TestEntityRecord'
        resource.getRecordBody()
        resource.omitBody()
        assert.deepEqual resource.recordBody, test: 'test9', type: 'Test::TestEntityRecord'
        yield return
  describe '#beforeUpdate', ->
    it 'should get body with ID', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
        Reflect.defineProperty resource, 'recordId',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'recordBody',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'context',
          writable: yes
          value: {
            pathParams: test_entity: 'ID123456'
            request: body: test_entity: test: 'test9'
          }
        # resource.context =
        #   pathParams: test_entity: 'ID123456'
        #   request: body: test_entity: test: 'test9'
        resource.getRecordId()
        resource.getRecordBody()
        resource.beforeUpdate()
        assert.deepEqual resource.recordBody, {id: 'ID123456', test: 'test9'}
        yield return
  describe '#list', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should list of resource items', ->
      co ->
        KEY = 'TEST_RESOURCE_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> TestRecord
          # @public init: FuncG([Object, CollectionInterface], NilT),
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestRecord'
          #     return
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public @async parseQuery: FuncG(
            [UnionG Object, QueryInterface]
            UnionG Object, String, QueryInterface
          ),
            default: (aoQuery) -> yield return aoQuery
          @public @async takeAll: FuncG([], CursorInterface),
            default: ->
              yield LeanRC::Cursor.new @, @getData().data
          @public @async executeQuery: FuncG(
            [UnionG Object, String, QueryInterface]
            CursorInterface
          ),
            default: (aoParsedQuery) ->
              data = _.filter @getData().data, aoParsedQuery.$filter
              yield return LeanRC::Cursor.new @, data
          @public @async push: FuncG(RecordInterface, RecordInterface),
            default: (aoRecord) ->
              isExist = (id) => (_.find @getData().data, {id})?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord.id = key
              i = aoRecord.toJSON()
              @getData().data.push i
              yield return aoRecord
          @public @async includes: FuncG([UnionG String, Number], Boolean),
            default: (id)->
              yield return (_.find @getData().data, {id})?
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
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
          url: 'http://localhost:8888/space/SPACE123/test_entitis'
          headers: 'x-forwarded-for': '192.168.0.1'
        res = new MyResponse
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        COLLECTION_NAME = 'TestEntitiesCollection'
        facade.registerProxy TestsCollection.new COLLECTION_NAME,
          delegate: 'TestRecord'
          # serializer: 'Serializer'
          data: []
        collection = facade.retrieveProxy COLLECTION_NAME
        yield collection.create test: 'test1'
        yield collection.create test: 'test2'
        resource = TestResource.new()
        resource.initializeNotifier KEY
        context = Test::Context.new req, res, switchMediator
        context.query = query: '{}'
        { items, meta } = yield resource.list context
        assert.deepEqual meta, pagination:
          limit: 'not defined'
          offset: 'not defined'
        assert.propertyVal items[0], 'test', 'test1'
        assert.propertyVal items[1], 'test', 'test2'
        yield return
  describe '#detail', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get resource single item', ->
      co ->
        KEY = 'TEST_RESOURCE_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> Test::TestRecord
          # @public init: FuncG([Object, CollectionInterface], NilT),
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestRecord'
          #     return
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String, { default: 'TestEntity' }
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public @async parseQuery: FuncG(
            [UnionG Object, QueryInterface]
            UnionG Object, String, QueryInterface
          ),
            default: (aoQuery) -> yield return aoQuery
          @public @async executeQuery: FuncG(
            [UnionG Object, String, QueryInterface]
            CursorInterface
          ),
            default: (aoParsedQuery) ->
              data = _.filter @getData().data, aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async push: FuncG(RecordInterface, RecordInterface),
            default: (aoRecord) ->
              isExist = (id) => (_.find @getData().data, {id})?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord.id = key
              i = aoRecord.toJSON()
              @getData().data.push i
              yield return aoRecord
          @public @async take: FuncG([UnionG String, Number], RecordInterface),
            default: (id) ->
              result = []
              if (data = _.find @getData().data, {id})?
                result.push data
              cursor = LeanRC::Cursor.new @, result
              return yield cursor.first()
          @public @async includes: FuncG([UnionG String, Number], Boolean),
            default: (id)->
              yield return (_.find @getData().data, {id})?
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
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
          url: 'http://localhost:8888/space/SPACE123/test_entitis'
          headers: 'x-forwarded-for': '192.168.0.1'
        res = new MyResponse
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        COLLECTION_NAME = 'TestEntitiesCollection'
        facade.registerProxy TestsCollection.new COLLECTION_NAME,
          delegate: 'TestRecord'
          serializer: -> LeanRC::Serializer
          data: []
        collection = facade.retrieveProxy COLLECTION_NAME
        yield collection.create test: 'test1'#, type: 'Test::TestRecord'
        record = yield collection.create test: 'test2'#, type: 'Test::TestRecord'
        resource = TestResource.new()
        resource.initializeNotifier KEY
        context = Test::Context.new req, res, switchMediator
        context.pathParams = "#{resource.keyName}": record.id
        result = yield resource.detail context
        assert.propertyVal result, 'id', record.id
        assert.propertyVal result, 'test', 'test2'
        yield return
  describe '#create', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should create resource single item', ->
      co ->
        KEY = 'TEST_RESOURCE_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> TestRecord
          # @public init: FuncG([Object, CollectionInterface], NilT),
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestRecord'
          #     return
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String, { default: 'TestEntity' }
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public @async parseQuery: FuncG(
            [UnionG Object, QueryInterface]
            UnionG Object, String, QueryInterface
          ),
            default: (aoQuery) -> yield return aoQuery
          @public @async executeQuery: FuncG(
            [UnionG Object, String, QueryInterface]
            CursorInterface
          ),
            default: (aoParsedQuery) ->
              data = _.filter @getData().data, aoParsedQuery.$filter
              yield return LeanRC::Cursor.new @, data
          @public @async push: FuncG(RecordInterface, RecordInterface),
            default: (aoRecord) ->
              isExist = (id) => (_.find @getData().data, {id})?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord.id = key
              i = aoRecord.toJSON()
              @getData().data.push i
              yield return aoRecord
          @public @async take: FuncG([UnionG String, Number], RecordInterface),
            default: (id) ->
              result = []
              if (data = _.find @getData().data, {id})?
                result.push data
              cursor = LeanRC::Cursor.new @, result
              return yield cursor.first()
          @public @async includes: FuncG([UnionG String, Number], Boolean),
            default: (id)->
              yield return (_.find @getData().data, {id})?
          @initialize()
        COLLECTION_NAME = 'TestEntitiesCollection'
        facade.registerProxy TestsCollection.new COLLECTION_NAME,
          delegate: 'TestRecord'
          # serializer: LeanRC::Serializer
          data: []
        collection = facade.retrieveProxy COLLECTION_NAME
        resource = TestResource.new()
        resource.initializeNotifier KEY
        Reflect.defineProperty resource, 'recordBody',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'context',
          writable: yes
          value: undefined
        ctx = request: body: test_entity: test: 'test3'
        result = yield resource.create ctx
        assert.propertyVal result, 'test', 'test3'
        yield return
  describe '#update', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should update resource single item', ->
      co ->
        KEY = 'TEST_RESOURCE_004'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> TestRecord
          # @public init: FuncG([Object, CollectionInterface], NilT),
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestRecord'
          #     return
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String, { default: 'TestEntity' }
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public @async parseQuery: FuncG(
            [UnionG Object, QueryInterface]
            UnionG Object, String, QueryInterface
          ),
            default: (aoQuery) -> yield return aoQuery
          @public @async executeQuery: FuncG(
            [UnionG Object, String, QueryInterface]
            CursorInterface
          ),
            default: (aoParsedQuery) ->
              data = _.filter @getData().data, aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async push: FuncG(RecordInterface, RecordInterface),
            default: (aoRecord) ->
              isExist = (id) => (_.find @getData().data, {id})?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord.id = key
              i = aoRecord.toJSON()
              @getData().data.push i
              yield return aoRecord
          @public @async override: FuncG([UnionG(String, Number), RecordInterface], RecordInterface),
            default: (id, aoRecord) ->
              item = _.find @getData().data, {id}
              if item?
                FORBIDDEN = [ '_key', '_id', '_type', '_rev' ]
                snapshot = _.omit (aoRecord.toJSON?() ? aoRecord ? {}), FORBIDDEN
                item[key] = value  for own key, value of snapshot
              # yield @take id
              yield return aoRecord
          @public @async take: FuncG([UnionG String, Number], RecordInterface),
            default: (id) ->
              result = []
              if (data = _.find @getData().data, {id})?
                result.push data
              cursor = LeanRC::Cursor.new @, result
              return yield cursor.first()
          @public @async includes: FuncG([UnionG String, Number], Boolean),
            default: (id)->
              yield return (_.find @getData().data, {id})?
          @initialize()
        COLLECTION_NAME = 'TestEntitiesCollection'
        facade.registerProxy TestCollection.new COLLECTION_NAME,
          delegate: 'TestRecord'
          serializer: LeanRC::Serializer
          data: []
        collection = facade.retrieveProxy COLLECTION_NAME
        resource = TestResource.new()
        resource.initializeNotifier KEY
        Reflect.defineProperty resource, 'recordId',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'recordBody',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'context',
          writable: yes
          value: undefined
        record = yield collection.create test: 'test3'
        ctx = {
          type: 'Test::TestRecord'
          pathParams: test_entity: record.id
          request: body: test_entity: test: 'test8'
        }
        result = yield resource.update ctx
        assert.propertyVal result, 'test', 'test8'
        yield return
  describe '#delete', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should remove resource single item', ->
      co ->
        KEY = 'TEST_RESOURCE_005'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> TestRecord
          # @public init: FuncG([Object, CollectionInterface], NilT),
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestRecord'
          #     return
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String, { default: 'TestEntity' }
          @initialize()
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public @async parseQuery: FuncG(
            [UnionG Object, QueryInterface]
            UnionG Object, String, QueryInterface
          ),
            default: (aoQuery) -> yield return aoQuery
          @public @async executeQuery: FuncG(
            [UnionG Object, String, QueryInterface]
            CursorInterface
          ),
            default: (aoParsedQuery) ->
              data = _.filter @getData().data, aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async push: FuncG(RecordInterface, RecordInterface),
            default: (aoRecord) ->
              isExist = (id) => (_.find @getData().data, {id})?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord.id = key
              i = aoRecord.toJSON()
              @getData().data.push i
              yield return aoRecord
          @public @async override: FuncG([UnionG(String, Number), RecordInterface], RecordInterface),
            default: (id, aoRecord) ->
              item = _.find @getData().data, {id}
              if item?
                FORBIDDEN = [ '_key', '_id', '_type', '_rev' ]
                snapshot = _.omit (aoRecord.toJSON?() ? aoRecord ? {}), FORBIDDEN
                item[key] = value  for own key, value of snapshot
              # yield @take id
              yield return aoRecord
          @public @async take: FuncG([UnionG String, Number], RecordInterface),
            default: (id) ->
              result = []
              if (data = _.find @getData().data, {id})?
                result.push data
              cursor = LeanRC::Cursor.new @, result
              return yield cursor.first()
          @public @async includes: FuncG([UnionG String, Number], Boolean),
            default: (id)->
              yield return (_.find @getData().data, {id})?
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
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
          url: 'http://localhost:8888/space/SPACE123/test_entitis'
          headers: 'x-forwarded-for': '192.168.0.1'
        res = new MyResponse
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        COLLECTION_NAME = 'TestEntitiesCollection'
        facade.registerProxy TestsCollection.new COLLECTION_NAME,
          delegate: 'TestRecord'
          # serializer: LeanRC::Serializer
          data: []
        collection = facade.retrieveProxy COLLECTION_NAME
        resource = TestResource.new()
        resource.initializeNotifier KEY
        context = Test::Context.new req, res, switchMediator
        record = yield collection.create test: 'test3'
        context.pathParams = test_entity: record.id
        result = yield resource.delete context
        assert.isUndefined result
        yield return
  describe '#execute', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should call execution', ->
      co ->
        KEY = 'TEST_RESOURCE_008'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> TestRecord
          # @public init: FuncG([Object, CollectionInterface], NilT),
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestRecord'
          #     return
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::QueryableResourceMixin
          @module Test
          @public entityName: String, { default: 'TestEntity' }
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @module Test
          @public jobs: Object, { default: {} }
          @public @async getDelayed: FuncG([], ListG StructG {
            queueName: String
            scriptName: String
            data: AnyT
            delay: MaybeG Number
            id: String
          }),
            default: ->
              yield return []
          @public init: Function,
            default: (args...) ->
              @super args...
              @jobs = {}
          @initialize()
        resque = TestResque.new LeanRC::RESQUE, data: []
        facade.registerProxy resque
        class TestsCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @module Test
          @public @async parseQuery: FuncG(
            [UnionG Object, QueryInterface]
            UnionG Object, String, QueryInterface
          ),
            default: (aoQuery) ->
              voQuery = _.mapKeys aoQuery, (value, key) -> key.replace /^@doc\./, ''
              voQuery = _.mapValues voQuery, (value, key) ->
                if value['$eq']? then value['$eq'] else value
              yield return $filter: voQuery
          @public @async executeQuery: FuncG(
            [UnionG Object, String, QueryInterface]
            CursorInterface
          ),
            default: (aoParsedQuery) ->
              data = _.filter @getData().data, aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async push: FuncG(RecordInterface, RecordInterface),
            default: (aoRecord) ->
              isExist = (id) => (_.find @getData().data, {id})?
              while isExist key = LeanRC::Utils.uuid.v4() then
              aoRecord.id = key
              i = aoRecord.toJSON()
              @getData().data.push i
              yield return aoRecord
          @public @async remove: FuncG([UnionG String, Number], NilT),
            default: (id) ->
              _.remove @getData().data, {id}
              yield return
          @public @async take: FuncG([UnionG String, Number], RecordInterface),
            default: (id) ->
              result = []
              if (data = _.find @getData().data, {id})?
                result.push data
              cursor = LeanRC::Cursor.new @, result
              return yield cursor.first()
          @public @async includes: FuncG([UnionG String, Number], Boolean),
            default: (id)->
              yield return (_.find @getData().data, {id})?
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
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
          url: 'http://localhost:8888/space/SPACE123/test_entitis'
          headers: 'x-forwarded-for': '192.168.0.1'
        res = new MyResponse
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends LeanRC::Switch
          @inheritProtected()
          @module Test
          @public routerName: String, { default: 'TEST_SWITCH_ROUTER' }
          @initialize()
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        COLLECTION_NAME = 'TestEntitiesCollection'
        facade.registerProxy TestsCollection.new COLLECTION_NAME,
          delegate: 'TestRecord'
          # serializer: LeanRC::Serializer
          data: []
        facade.registerMediator LeanRC::Mediator.new LeanRC::APPLICATION_MEDIATOR,
          context: {}
        collection = facade.retrieveProxy COLLECTION_NAME
        resource = TestResource.new()
        resource.initializeNotifier KEY
        context = Test::Context.new req, res, switchMediator
        context.query = query: '{"test":{"$eq":"test2"}}'
        yield collection.create test: 'test1'
        yield collection.create test: 'test2'
        yield collection.create test: 'test2'
        spySendNotitfication = sinon.spy resource, 'sendNotification'
        testBody =
          context: context
          reverse: 'TEST_REVERSE'
        notification = LeanRC::Notification.new 'TEST_NAME', testBody, 'list'
        yield resource.execute notification
        [ name, body, type ] = spySendNotitfication.lastCall.args
        assert.equal name, LeanRC::HANDLER_RESULT
        assert.isUndefined body.error, body.error
        {result, resource:voResource} = body
        { meta, items } = result
        assert.deepEqual meta, pagination:
          limit: 50
          offset: 0
        assert.deepEqual voResource, resource
        assert.lengthOf items, 3
        assert.equal type, 'TEST_REVERSE'
        yield return
  describe '#checkApiVersion', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should check API version', ->
      co ->
        KEY = 'TEST_RESOURCE_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @action test: Function,
            default: ->
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
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
          @initialize()
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        resource = TestResource.new()
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
        yield return
  describe '#setOwnerId', ->
    it 'should get owner ID for body', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
        Reflect.defineProperty resource, 'recordId',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'recordBody',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'session',
          writable: yes
          value: uid: 'ID123'
        ctx = {
          pathParams: test_entity: 'ID123456'
          request: body: test_entity: test: 'test9'
        }
        Reflect.defineProperty resource, 'context',
          writable: yes
          value: ctx
        # resource.session = uid: 'ID123'
        # resource.context =
        #   pathParams: test_entity: 'ID123456'
        #   request: body: test_entity: test: 'test9'
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
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
        Reflect.defineProperty resource, 'recordId',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'recordBody',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'session',
          writable: yes
          value: uid: 'ID123'
        ctx = {
          pathParams: test_entity: 'ID123456'
          request: body: test_entity: test: 'test9'
        }
        Reflect.defineProperty resource, 'context',
          writable: yes
          value: ctx
        # resource.session = uid: 'ID123'
        # resource.context =
        #   pathParams: test_entity: 'ID123456'
        #   request: body: test_entity: test: 'test9'
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
  ###
  # Moved to:
  #   -> AdminingResourceMixin
  #   -> ModellingResourceMixin
  #   -> PersoningResourceMixin
  #   -> SharingResourceMixin
  describe '#setSpaces', ->
    it 'should set space ID for body', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
        resource.currentUser = id: 'ID123'
        resource.context =
          pathParams: test_entity: 'ID123456', space: 'SPACE123'
          request: body: test_entity: test: 'test9'
        resource.getRecordId()
        resource.getRecordBody()
        resource.beforeUpdate()
        yield resource.setSpaces()
        assert.deepEqual resource.recordBody,
          test: 'test9'
          id: 'ID123456'
          spaces: ['SPACE123']
        yield return
  describe '#protectSpaces', ->
    it 'should omit space ID from body', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
        resource.currentUser = id: 'ID123'
        resource.context =
          pathParams: test_entity: 'ID123456', space: 'SPACE123'
          request: body: test_entity: test: 'test9'
        resource.getRecordId()
        resource.getRecordBody()
        resource.beforeUpdate()
        yield resource.setSpaces()
        assert.deepEqual resource.recordBody,
          test: 'test9'
          id: 'ID123456'
          spaces: ['SPACE123']
        yield resource.protectSpaces()
        assert.deepEqual resource.recordBody,
          test: 'test9'
          id: 'ID123456'
        yield return
  ###
  describe '#filterOwnerByCurrentUser', ->
    it 'should update query if caller user is not admin', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
          @initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        resource = TestResource.new()
        Reflect.defineProperty resource, 'recordId',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'recordBody',
          writable: yes
          value: undefined
        Reflect.defineProperty resource, 'session',
          writable: yes
          value: uid: 'ID123', userIsAdmin: no
        ctx = {
          pathParams: test_entity: 'ID123456', space: 'SPACE123'
          request: body: test_entity: test: 'test9'
        }
        Reflect.defineProperty resource, 'context',
          writable: yes
          value: ctx
        # resource.session = uid: 'ID123', userIsAdmin: no
        # resource.context =
        #   pathParams: test_entity: 'ID123456', space: 'SPACE123'
        #   request: body: test_entity: test: 'test9'
        resource.getRecordId()
        resource.getRecordBody()
        resource.beforeUpdate()
        yield resource.filterOwnerByCurrentUser()
        assert.deepEqual resource.listQuery, $filter: '@doc.ownerId': '$eq': 'ID123'
        yield return
  describe '#checkOwner', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should check if user is resource owner', ->
      co ->
        KEY = 'TEST_RESOURCE_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
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
          @initialize()
        class TestEntityRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute ownerId: String
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> TestEntityRecord
          # @public init: FuncG([Object, CollectionInterface], NilT),
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestEntityRecord'
          #     return
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        resource = TestResource.new()
        resource.initializeNotifier KEY
        { collectionName } = resource
        boundCollection = TestCollection.new collectionName,
          delegate: 'TestEntityRecord'
        facade.registerProxy boundCollection
        yield boundCollection.create id: 'ID123456', test: 'test', ownerId: 'ID124'
        yield boundCollection.create id: 'ID123457', test: 'test', ownerId: 'ID123'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        resource = TestResource.new()
        resource.initializeNotifier KEY
        resource.context = Test::Context.new req, res, switchMediator
        resource.context.pathParams = test_entity: 'ID123455', space: 'SPACE123'
        resource.context.request.body = test_entity: test: 'test9'
        resource.getRecordId()
        resource.getRecordBody()
        resource.beforeUpdate()
        resource.session = {}
        try
          yield resource.checkOwner()
        catch e
        assert.instanceOf e, httpErrors.Unauthorized
        resource.session = uid: 'ID123', userIsAdmin: no
        resource.context.pathParams.test_entity = 'ID0123456'
        # resource.session = uid: '123456789'
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
        yield return
  describe '#checkExistence', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should check if entity exists', ->
      co ->
        KEY = 'TEST_RESOURCE_102'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
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
          @initialize()
        class TestEntityRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute ownerId: String
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> Test::TestEntityRecord
          # @public init: FuncG([Object, CollectionInterface], NilT),
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestEntityRecord'
          #     return
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        resource = TestResource.new()
        resource.initializeNotifier KEY
        { collectionName } = resource
        boundCollection = TestCollection.new collectionName,
          delegate: 'TestEntityRecord'
        facade.registerProxy boundCollection
        yield boundCollection.create id: 'ID123456', test: 'test', ownerId: 'ID124'
        yield boundCollection.create id: 'ID123457', test: 'test', ownerId: 'ID123'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        resource = TestResource.new()
        resource.initializeNotifier KEY
        resource.context = Test::Context.new req, res, switchMediator
        resource.context.pathParams = test_entity: 'ID123455', space: 'SPACE123'
        resource.context.request.body = test_entity: test: 'test9'
        resource.getRecordId()
        resource.session = uid: 'ID123', userIsAdmin: no
        try
          yield resource.checkExistence()
        catch e
        assert.instanceOf e, httpErrors.NotFound
        resource.context.pathParams.test_entity = 'ID123457'
        resource.getRecordId()
        yield resource.checkExistence()
        yield return
  ### removed???
  describe '#requiredAuthorizationHeader', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should if authorization header exists and valid', ->
      co ->
        KEY = 'TEST_RESOURCE_103'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
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
        resource = TestResource.new()
        resource.initializeNotifier KEY
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        resource = TestResource.new()
        resource.initializeNotifier KEY
        resource.context = Test::Context.new req, res, switchMediator
        try
          yield resource.requiredAuthorizationHeader()
        catch err1
        assert.instanceOf err1, httpErrors.Unauthorized
        resource.context.request.headers.authorization = "Auth"
        try
          yield resource.requiredAuthorizationHeader()
        catch err2
        assert.instanceOf err2, httpErrors.Unauthorized
        resource.context.request.headers.authorization = 'Bearer QWERTYUIOPLKJHGFDSA'
        try
          yield resource.requiredAuthorizationHeader()
        catch err3
        assert.instanceOf err3, httpErrors.Unauthorized
        resource.context.request.headers.authorization = "Bearer #{configs.apiKey}"
        try
          yield resource.requiredAuthorizationHeader()
        catch err4
        assert.isUndefined err4
        yield return
  ###
  describe '#adminOnly', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should check if user is administrator', ->
      co ->
        KEY = 'TEST_RESOURCE_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
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
          @initialize()
        class TestEntityRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @attribute ownerId: String
          @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
            default: (asType) -> Test::TestEntityRecord
          # @public init: FuncG([Object, CollectionInterface], NilT),
          #   default: ->
          #     @super arguments...
          #     @type = 'Test::TestEntityRecord'
          #     return
          @initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @initialize()
        resource = TestResource.new()
        resource.initializeNotifier KEY
        { collectionName } = resource
        boundCollection = TestCollection.new collectionName,
          delegate: TestEntityRecord
        facade.registerProxy boundCollection
        yield boundCollection.create id: 'ID123456', test: 'test', ownerId: 'ID124'
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        resource = TestResource.new()
        resource.initializeNotifier KEY
        resource.context = Test::Context.new req, res, switchMediator
        resource.context.pathParams = test_entity: 'ID123456', space: 'SPACE123'
        resource.context.request.body = test_entity: test: 'test9'
        resource.getRecordId()
        resource.getRecordBody()
        resource.beforeUpdate()
        resource.session = {}
        try
          yield resource.checkOwner()
        catch e
        assert.instanceOf e, httpErrors.Unauthorized
        resource.session = uid: 'ID123'
        try
          yield resource.adminOnly()
        catch e
        assert.instanceOf e, httpErrors.Forbidden
        resource.session = uid: 'ID123', userIsAdmin: yes
        yield resource.adminOnly()
        yield return
  describe '#doAction', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should run specified action', ->
      co ->
        KEY = 'TEST_RESOURCE_104'
        facade = LeanRC::Facade.getInstance KEY
        testAction = sinon.spy -> yield return yes
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @module Test
          @public jobs: Object, { default: {} }
          @public @async getDelayed: FuncG([], ListG StructG {
            queueName: String
            scriptName: String
            data: AnyT
            delay: MaybeG Number
            id: String
          }),
            default: ->
              yield return []
          @public init: FuncG([MaybeG(String), MaybeG AnyT], NilT),
            default: (args...) ->
              @super args...
              @jobs = {}
              return
          @initialize()
        resque = TestResque.new LeanRC::RESQUE, data: []
        facade.registerProxy resque
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @action @async test: Function,
            default: testAction
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
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
          @initialize()
        resource = TestResource.new()
        resource.initializeNotifier KEY
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        resource = TestResource.new()
        resource.initializeNotifier KEY
        context = Test::Context.new req, res, switchMediator
        yield resource.doAction 'test', context
        assert.isTrue testAction.calledWith context
        yield return
  describe '#saveDelayeds', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should save delayed jobs from cache into queue', ->
      co ->
        MULTITON_KEY = 'TEST_RESOURCE_105|>123456765432'
        facade = LeanRC::Facade.getInstance MULTITON_KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @module Test
          @public jobs: Object, { default: {} }
          @public @async ensureQueue: FuncG([String, MaybeG Number], StructG name: String, concurrency: Number),
            default: (asQueueName, anConcurrency) ->
              queue = _.find @getData().data, name: asQueueName
              if queue?
                queue.concurrency = anConcurrency
              else
                queue = name: asQueueName, concurrency: anConcurrency
                @getData().data.push queue
              yield return queue
          @public @async getQueue: FuncG(String, MaybeG StructG name: String, concurrency: Number),
            default: (asQueueName) ->
              yield return _.find @getData().data, name: asQueueName
          @public @async pushJob: FuncG([String, String, AnyT, MaybeG Number], UnionG String, Number),
            default: (name, scriptName, data, delayUntil) ->
              id = LeanRC::Utils.uuid.v4()
              @jobs[id] = { name, scriptName, data, delayUntil }
              yield return id
          @public init: Function,
            default: (args...) ->
              @super args...
              @jobs = {}
          @initialize()
        resque = TestResque.new LeanRC::RESQUE, data: []
        facade.registerProxy resque
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @initialize()
        resource = TestResource.new()
        resource.initializeNotifier MULTITON_KEY
        DELAY = Date.now() + 1000000
        yield resque.create 'TEST_QUEUE_1', 4
        yield resque.delay 'TEST_QUEUE_1', 'TestScript', { data: 'data1' }, DELAY
        yield resque.delay 'TEST_QUEUE_1', 'TestScript', { data: 'data2' }, DELAY
        yield resque.delay 'TEST_QUEUE_1', 'TestScript', { data: 'data3' }, DELAY
        yield resque.delay 'TEST_QUEUE_1', 'TestScript', { data: 'data4' }, DELAY
        yield resource.saveDelayeds { facade }
        delayeds = resque.jobs
        index = 0
        for id, delayed of delayeds
          assert.isDefined delayed
          assert.isNotNull delayed
          assert.include delayed,
            name: 'TEST_QUEUE_1'
            scriptName: 'TestScript'
            delayUntil: DELAY
          assert.deepEqual delayed.data, data: "data#{index + 1}"
          ++index
        yield return
  describe '#writeTransaction', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should test if transaction is needed', ->
      co ->
        KEY = 'TEST_RESOURCE_106'
        facade = LeanRC::Facade.getInstance KEY
        testAction = sinon.spy -> yield return
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @module Test
          @action @async test: Function,
            default: testAction
          @initialize()
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
          @initialize()
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
          @initialize()
        resource = TestResource.new()
        resource.initializeNotifier KEY
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        resource = TestResource.new()
        resource.initializeNotifier KEY
        context = Test::Context.new req, res, switchMediator
        assert.isFalse yield resource.writeTransaction 'test', context
        context.request.method = 'POST'
        assert.isTrue yield resource.writeTransaction 'test', context
        yield return
