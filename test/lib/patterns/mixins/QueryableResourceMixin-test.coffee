EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
Resource = LeanRC::Resource
{ co } = LeanRC::Utils

describe 'QueryableResourceMixin', ->
  facade = null
  after -> facade?.remove?()
  describe '#list', ->
    it 'should list of resource items', ->
      co ->
        KEY = 'TEST_RESOURCE_QUERYABLE_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        configs = LeanRC::Configuration.new LeanRC::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestRouter extends LeanRC::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attribute test: String
          @public @static findRecordByName: Function,
            default: (asType) -> Test::TestRecord
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        TestRecord.initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::QueryableResourceMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        TestResource.initialize()
        class TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::QueryableCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @public parseQuery: Object,
            default: (aoQuery) ->
              if aoQuery.$filter?
                aoQuery.$filter = _.mapKeys aoQuery.$filter, (value, key) ->
                  key.replace '@doc.', ''
              aoQuery
          @public @async takeAll: Function,
            default: ->
              yield LeanRC::Cursor.new @, @getData().data
          @public @async executeQuery: Function,
            default: (aoParsedQuery) ->
              data = _.filter @getData().data, aoParsedQuery.$filter
              yield LeanRC::Cursor.new @, data
          @public @async push: Function,
            default: (aoRecord) ->
              @getData().data.push aoRecord.toJSON()
              yield yes
        TestCollection.initialize()
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
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        COLLECTION_NAME = 'TestEntitiesCollection'
        facade.registerProxy TestCollection.new COLLECTION_NAME,
          delegate: TestRecord
          serializer: LeanRC::Serializer
          data: []
        collection = facade.retrieveProxy COLLECTION_NAME
        yield collection.create test: 'test1'
        yield collection.create test: 'test2'
        resource = TestResource.new()
        resource.initializeNotifier KEY
        context = Test::Context.new req, res, switchMediator
        { items, meta } = yield resource.list context
        assert.deepEqual meta, pagination:
          limit: 50
          offset: 0
        assert.propertyVal items[0], 'test', 'test1'
        assert.propertyVal items[1], 'test', 'test2'
        req.url = 'http://localhost:8888/space/SPACE123/test_entity/ID123456?query={"$filter":{"@doc.test":"test2"}}'
        resource = TestResource.new()
        resource.initializeNotifier KEY
        context = Test::Context.new req, res, switchMediator
        { items, meta } = yield resource.list context
        assert.propertyVal items[0], 'test', 'test2'
        yield return
