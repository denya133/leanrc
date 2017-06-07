EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
# httpErrors = require 'http-errors'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'BodyParseMixin', ->
  describe '.new', ->
    it 'should create new resource', ->
      expect ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::BodyParseMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        Test::TestResource.initialize()
        resource = Test::TestResource.new()
      .to.not.throw Error
  ###
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
  describe '#adminOnly', ->
    it 'should check if user is administrator', ->
      co ->
        KEY = 'TEST_RESOURCE_003'
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
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        resource = Test::TestResource.new()
        resource.initializeNotifier KEY
        resource.currentUser = id: 'ID123', isAdmin: no
        resource.context = Test::Context.new req, res, switchMediator
        resource.context.pathParams = test_entity: 'ID123456', space: 'SPACE123'
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
          yield resource.adminOnly()
        catch e
        assert.instanceOf e, httpErrors.Forbidden
        resource.currentUser.isAdmin = yes
        yield resource.adminOnly()
        facade.remove()
        yield return
  ###
