{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'
Router = LeanRC::Router

describe 'Router', ->
  describe '.new, .map', ->
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
