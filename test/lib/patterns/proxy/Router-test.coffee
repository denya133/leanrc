{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'
Router = LeanRC::Router

describe 'Router', ->
  describe '.new, .map, #map, #resource, #namespace, #routes', ->
    it 'should create new router', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @Module: Test
          @map ->
            @resource 'test2', ->
              @resource 'test2'
            @namespace 'sub2', ->
              @resource 'subtest2'
        Test::TestRouter.initialize()
        router = Test::TestRouter.new 'TEST_ROUTER'
        assert.lengthOf router.routes, 18, 'Routes did not initialized'
      .to.not.throw Error
  describe '#defineMethod', ->
    it 'should define methods for router', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @Module: Test
          @map ->
            @resource 'test2'
            @defineMethod [], 'get', '/get', resource: 'test2'
            @defineMethod [], 'post', '/post', resource: 'test2'
            @defineMethod [], 'put', '/put', resource: 'test2'
        Test::TestRouter.initialize()
        spyDefineMethod = sinon.spy Test::TestRouter::, 'defineMethod'
        router = Test::TestRouter.new 'TEST_ROUTER'
        assert.equal spyDefineMethod.callCount, 3, 'Methods did not defined'
      .to.not.throw Error
    it 'should define `get` method for router', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @Module: Test
          @map ->
            @resource 'test2', ->
            @get 'test3', resource: 'test2'
        Test::TestRouter.initialize()
        spyDefineMethod = sinon.spy Test::TestRouter::, 'defineMethod'
        router = Test::TestRouter.new 'TEST_ROUTER'
        assert.equal spyDefineMethod.callCount, 1, 'Methods did not defined'
      .to.not.throw Error
  describe '#post', ->
    it 'should define `post` method for router', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @Module: Test
          @map ->
            @resource 'test2', ->
            @post 'test3', resource: 'test2'
        Test::TestRouter.initialize()
        spyDefineMethod = sinon.spy Test::TestRouter::, 'defineMethod'
        router = Test::TestRouter.new 'TEST_ROUTER'
        assert.equal spyDefineMethod.callCount, 1, 'Methods did not defined'
      .to.not.throw Error
  describe '#put', ->
    it 'should define `put` method for router', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @Module: Test
          @map ->
            @resource 'test2', ->
            @put 'test3', resource: 'test2'
        Test::TestRouter.initialize()
        spyDefineMethod = sinon.spy Test::TestRouter::, 'defineMethod'
        router = Test::TestRouter.new 'TEST_ROUTER'
        assert.equal spyDefineMethod.callCount, 1, 'Methods did not defined'
      .to.not.throw Error
  describe '#patch', ->
    it 'should define `patch` method for router', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @Module: Test
          @map ->
            @resource 'test2', ->
            @patch 'test3', resource: 'test2'
        Test::TestRouter.initialize()
        spyDefineMethod = sinon.spy Test::TestRouter::, 'defineMethod'
        router = Test::TestRouter.new 'TEST_ROUTER'
        assert.equal spyDefineMethod.callCount, 1, 'Methods did not defined'
      .to.not.throw Error
  describe '#delete', ->
    it 'should define `delete` method for router', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @Module: Test
          @map ->
            @resource 'test2', ->
            @delete 'test3', resource: 'test2'
        Test::TestRouter.initialize()
        spyDefineMethod = sinon.spy Test::TestRouter::, 'defineMethod'
        router = Test::TestRouter.new 'TEST_ROUTER'
        assert.equal spyDefineMethod.callCount, 1, 'Methods did not defined'
      .to.not.throw Error
  describe '#member', ->
    it 'should define `member` method for router', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @Module: Test
          @map ->
            @resource 'test2', except: 'patch', ->
              @member ->
                @post 'test4'
                @get 'test5'
        Test::TestRouter.initialize()
        spyDefineMethod = sinon.spy Test::TestRouter::, 'defineMethod'
        router = Test::TestRouter.new 'TEST_ROUTER'
        assert.lengthOf router.routes, 7, 'Methods did not defined'
      .to.not.throw Error
  describe '#collection', ->
    it 'should define `collection` method for router', ->
      expect ->
        class Test extends RC::Module
        class Test::TestRouter extends LeanRC::Router
          @inheritProtected()
          @Module: Test
          @map ->
            @resource 'test2', except: 'patch', ->
              @collection ->
                @post 'test4'
                @get 'test5'
        Test::TestRouter.initialize()
        spyDefineMethod = sinon.spy Test::TestRouter::, 'defineMethod'
        router = Test::TestRouter.new 'TEST_ROUTER'
        assert.lengthOf router.routes, 7, 'Methods did not defined'
      .to.not.throw Error
