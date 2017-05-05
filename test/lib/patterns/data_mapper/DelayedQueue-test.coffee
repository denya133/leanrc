{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'DelayedQueue', ->
  describe '.new', ->
    it 'should create delayed queue instance', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::Resque extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
        Test::Resque.initialize()
        class Test::DelayedQueue extends LeanRC::DelayedQueue
          @inheritProtected()
          @module Test
        Test::DelayedQueue.initialize()
        queue = Test::DelayedQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , Test::Resque.new()
        assert.property queue, 'name', 'TEST_QUEUE', 'No correct `id` property'
        assert.property queue, 'concurrency', 4, 'No correct `rev` property'
        assert.instanceOf queue.resque, Test::Resque, '`resque` is not a Resque instance'
        yield return
