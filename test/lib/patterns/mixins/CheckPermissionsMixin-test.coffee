### Moved to *ing mixins
{ IncomingMessage, ServerResponse } = require 'http'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
httpErrors = require 'http-errors'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'CheckPermissionsMixin', ->
  describe '.new', ->
    it 'should create new resource', ->
      expect ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class TestResource extends LeanRC::Resource
          @inheritProtected()
          @include LeanRC::CheckPermissionsMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        TestResource.initialize()
        resource = Test::TestResource.new()
      .to.not.throw Error
  describe '#_checkOwner', ->
    it 'should check if resource owner is matched', ->
      co ->
        KEY = 'TEST_CHECK_PERMISSIONS_MIXIN_001'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        facade = Test::Facade.getInstance KEY
        configs = Test::Configuration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends Test::Resource
          @inheritProtected()
          @include Test::CheckPermissionsMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        TestResource.initialize()
        class TestRouter extends Test::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Test::Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        MemoryCollection.initialize()
        class Space extends Test::Record
          @inheritProtected()
          @module Test
          @attribute ownerId: String
        Space.initialize()
        facade.registerProxy MemoryCollection.new Test::SPACES,
          delegate: Space
          serializer: Test::Serializer
        body = '{"test":"test"}'
        class MyRequest extends IncomingMessage
          constructor: (socket) ->
            super socket
            @method = 'POST'
            @url = 'http://localhost:8888/space/SPACE123/test_entity'
            @headers =
              'x-forwarded-for': '192.168.0.1'
              'content-type': 'application/json'
              'content-length': "#{body.length}"
            @push body
            @push null
        class MyResponse extends ServerResponse
        req = new MyRequest
        res = new MyResponse req
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        spaces = facade.retrieveProxy Test::SPACES
        space = yield spaces.create id: 'XXX', ownerId: 'YYY'
        resource = Test::TestResource.new()
        resource.context = Test::Context.new req, res, switchMediator
        resource.initializeNotifier KEY
        { pointer: key } = Test::TestResource.instanceMethods['_checkOwner']
        isOwner = yield resource[key] 'XXX', 'YYY'
        assert.isTrue isOwner
        isOwner = yield resource[key] 'XXX', 'YYY12'
        assert.isFalse isOwner
        facade.remove()
        yield return
  describe '#_checkRole', ->
    it 'should check if resource owner is matched', ->
      co ->
        KEY = 'TEST_CHECK_PERMISSIONS_MIXIN_002'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        facade = Test::Facade.getInstance KEY
        configs = Test::Configuration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends Test::Resource
          @inheritProtected()
          @include Test::CheckPermissionsMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        TestResource.initialize()
        class TestRouter extends Test::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Test::Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @public @async findBy: Function,
            default: (query) ->
              item = _.chain @[Symbol.for '~collection']
                .values()
                .find query
                .value()
              result = if item? then [ item ] else []
              yield return LeanRC::Cursor.new @, result
        MemoryCollection.initialize()
        class Role extends Test::Record
          @inheritProtected()
          @module Test
          @attribute spaceId: String
          @attribute userId: String
          @attribute rules: Object
        Role.initialize()
        facade.registerProxy MemoryCollection.new Test::ROLES,
          delegate: Role
          serializer: Test::Serializer
        body = '{"test":"test"}'
        class MyRequest extends IncomingMessage
          constructor: (socket) ->
            super socket
            @method = 'POST'
            @url = 'http://localhost:8888/space/SPACE123/test_entity'
            @headers =
              'x-forwarded-for': '192.168.0.1'
              'content-type': 'application/json'
              'content-length': "#{body.length}"
            @push body
            @push null
        class MyResponse extends ServerResponse
        req = new MyRequest
        res = new MyResponse req
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        roles = facade.retrieveProxy Test::ROLES
        yield roles.create
          id: 'AAA1'
          spaceId: 'XXX'
          userId: 'YYY1'
          rules: system: administrator: yes
        yield roles.create
          id: 'AAA2'
          spaceId: 'XXX'
          userId: 'YYY2'
          rules: moderator: 'Test::TestResource': yes
        yield roles.create
          id: 'AAA3'
          spaceId: 'XXX'
          userId: 'YYY3'
          rules: 'Test::TestResource': create: yes
        resource = Test::TestResource.new()
        resource.context = Test::Context.new req, res, switchMediator
        resource.initializeNotifier KEY
        { pointer: key } = Test::TestResource.instanceMethods['_checkRole']
        isRole = yield resource[key] 'XXX', 'YYY', 'ZZZ'
        assert.isFalse isRole
        isRole = yield resource[key] 'XXX', 'YYY1', 'ZZZ'
        assert.isTrue isRole
        isRole = yield resource[key] 'XXX', 'YYY2', 'ZZZ'
        assert.isTrue isRole
        isRole = yield resource[key] 'XXX', 'YYY3', 'create'
        assert.isTrue isRole
        facade.remove()
        yield return
  describe '#_checkPermission', ->
    it 'should check if permission is enough', ->
      co ->
        KEY = 'TEST_CHECK_PERMISSIONS_MIXIN_003'
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        facade = Test::Facade.getInstance KEY
        configs = Test::Configuration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends Test::Resource
          @inheritProtected()
          @include Test::CheckPermissionsMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
        TestResource.initialize()
        class TestRouter extends Test::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Test::Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @public @async findBy: Function,
            default: (query) ->
              item = _.chain @[Symbol.for '~collection']
                .values()
                .find query
                .value()
              result = if item? then [ item ] else []
              yield return LeanRC::Cursor.new @, result
        MemoryCollection.initialize()
        class Role extends Test::Record
          @inheritProtected()
          @module Test
          @attribute spaceId: String
          @attribute userId: String
          @attribute rules: Object
        Role.initialize()
        class Space extends Test::Record
          @inheritProtected()
          @module Test
          @attribute ownerId: String
        Space.initialize()
        facade.registerProxy MemoryCollection.new Test::SPACES,
          delegate: Space
          serializer: Test::Serializer
        facade.registerProxy MemoryCollection.new Test::ROLES,
          delegate: Role
          serializer: Test::Serializer
        body = '{"test":"test"}'
        class MyRequest extends IncomingMessage
          constructor: (socket) ->
            super socket
            @method = 'POST'
            @url = 'http://localhost:8888/space/SPACE123/test_entity'
            @headers =
              'x-forwarded-for': '192.168.0.1'
              'content-type': 'application/json'
              'content-length': "#{body.length}"
            @push body
            @push null
        class MyResponse extends ServerResponse
        req = new MyRequest
        res = new MyResponse req
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
        spaces = facade.retrieveProxy Test::SPACES
        space = yield spaces.create id: 'XXX', ownerId: 'YYY'
        roles = facade.retrieveProxy Test::ROLES
        yield roles.create
          id: 'AAA1'
          spaceId: 'XXX'
          userId: 'YYY1'
          rules: system: administrator: yes
        yield roles.create
          id: 'AAA2'
          spaceId: 'XXX'
          userId: 'YYY2'
          rules: moderator: 'Test::TestResource': yes
        yield roles.create
          id: 'AAA3'
          spaceId: 'XXX'
          userId: 'YYY3'
          rules: 'Test::TestResource': create: yes
        resource = Test::TestResource.new()
        resource.context = Test::Context.new req, res, switchMediator
        resource.currentUser = id: 'YYY2'
        resource.initializeNotifier KEY
        { pointer: key } = Test::TestResource.instanceMethods['_checkPermission']
        try
          hasPermissions = yield resource[key] 'XXX', 'ZZZ'
        catch e1
          hasPermissions = no
        assert.isTrue hasPermissions
        assert.isUndefined e1
        try
          resource.currentUser.id = 'YYY4'
          hasPermissions = yield resource[key] 'XXX', 'ZZZ'
        catch e2
          hasPermissions = no
        assert.isFalse hasPermissions
        assert.instanceOf e2, httpErrors.Forbidden
        assert.propertyVal e2, 'message', 'Current user has no access'
        facade.remove()
        yield return
  describe '#checkPermission', ->
    facade = null
    KEY = 'TEST_CHECK_PERMISSIONS_MIXIN_004'
    after ->
      facade?.remove?()
    it 'should check if permission is enough', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        facade = Test::Facade.getInstance KEY
        configs = Test::Configuration.new Test::CONFIGURATION, Test::ROOT
        facade.registerProxy configs
        class TestResource extends Test::Resource
          @inheritProtected()
          @include Test::CheckPermissionsMixin
          @module Test
          @public entityName: String,
            default: 'TestEntity'
          @initialHook 'checkPermission'
        TestResource.initialize()
        class TestRouter extends Test::Router
          @inheritProtected()
          @module Test
        TestRouter.initialize()
        facade.registerProxy TestRouter.new 'TEST_SWITCH_ROUTER'
        class TestSwitch extends Test::Switch
          @inheritProtected()
          @module Test
          @public routerName: String,
            configurable: yes
            default: 'TEST_SWITCH_ROUTER'
        TestSwitch.initialize()
        class MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
          @public @async findBy: Function,
            default: (query) ->
              item = _.chain @[Symbol.for '~collection']
                .values()
                .find query
                .value()
              result = if item? then [ item ] else []
              yield return LeanRC::Cursor.new @, result
        MemoryCollection.initialize()
        class Role extends Test::Record
          @inheritProtected()
          @module Test
          @attribute spaceId: String
          @attribute userId: String
          @attribute rules: Object
        Role.initialize()
        class Space extends Test::Record
          @inheritProtected()
          @module Test
          @attribute ownerId: String
        Space.initialize()
        facade.registerProxy MemoryCollection.new Test::SPACES,
          delegate: Space
          serializer: Test::Serializer
        facade.registerProxy MemoryCollection.new Test::ROLES,
          delegate: Role
          serializer: Test::Serializer
        body = '{"test":"test"}'
        class MyRequest extends IncomingMessage
          constructor: (socket) ->
            super socket
            @method = 'POST'
            @url = 'http://localhost:8888/space/SPACE123/test_entity'
            @headers =
              'x-forwarded-for': '192.168.0.1'
              'content-type': 'application/json'
              'content-length': "#{body.length}"
            @push body
            @push null
        class MyResponse extends ServerResponse
        facade.registerMediator TestSwitch.new 'TEST_SWITCH_MEDIATOR'
        switchMediator = facade.retrieveMediator 'TEST_SWITCH_MEDIATOR'
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
        spaces = facade.retrieveProxy Test::SPACES
        space = yield spaces.create id: 'XXX', ownerId: 'YYY3'
        roles = facade.retrieveProxy Test::ROLES
        yield roles.create
          id: 'AAA1'
          spaceId: 'XXX'
          userId: 'YYY1'
          rules: system: administrator: yes
        yield roles.create
          id: 'AAA2'
          spaceId: 'XXX'
          userId: 'YYY2'
          rules: moderator: 'Test::TestResource': yes
        yield roles.create
          id: 'AAA3'
          spaceId: 'XXX'
          userId: 'YYY3'
          rules: 'Test::TestResource': list: yes
        resource = Test::TestResource.new()
        { collectionName } = resource
        boundCollection = MemoryCollection.new collectionName,
          delegate: TestEntity
        facade.registerProxy boundCollection
        req = new MyRequest
        res = new MyResponse req
        voContext = Test::Context.new req, res, switchMediator
        voContext.pathParams = space: 'XXX'
        resource.context = voContext
        resource.currentUser = id: 'YYY', role: 'user'
        resource.currentUser.isAdmin = no
        resource.initializeNotifier KEY
        try
          yield resource.checkPermission()
        catch error1
        assert.instanceOf error1, httpErrors.Forbidden
        assert.propertyVal error1, 'message', 'Current user has no access'
        resource.currentUser.role = 'admin'
        resource.currentUser.isAdmin = yes
        yield resource.checkPermission()
        resource.currentUser.role = 'user'
        resource.currentUser.isAdmin = no
        try
          yield resource.list voContext
        catch error2
        assert.instanceOf error2, httpErrors.Forbidden
        assert.propertyVal error2, 'message', 'Current user has no access'
        req = new MyRequest
        res = new MyResponse req
        voContext = Test::Context.new req, res, switchMediator
        voContext.pathParams = space: 'XXX'
        resource.currentUser = id: 'YYY3', role: 'user'
        resource.currentUser.isAdmin = no
        try
          yield resource.list voContext
        catch error3
        assert.isUndefined error3
        yield return
###
