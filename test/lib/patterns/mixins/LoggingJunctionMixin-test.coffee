{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'LoggingJunctionMixin', ->
  describe '.new', ->
    it 'should create new JunctionMediator instance with LoggingJunctionMixin', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class TestJunctionMediator extends LeanRC::Pipes::JunctionMediator
          @inheritProtected()
          @include LeanRC::LoggingJunctionMixin
          @module Test
        TestJunctionMediator.initialize()
        mediator = TestJunctionMediator.new 'TEST_MEDIATOR', LeanRC::Pipes::Junction.new()
        assert.instanceOf mediator, LeanRC::Pipes::JunctionMediator
        assert.instanceOf mediator[Symbol.for '~junction'], LeanRC::Pipes::Junction
        yield return
