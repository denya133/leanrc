{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
RC = require 'RC'
LeanRC = require.main.require 'lib'
{ co } = RC::Utils


describe 'Resque', ->
  describe '.new', ->
    it 'should create resque instance', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @module Test
        Test::Resque.initialize()
        resque = Test::Resque.new 'TEST_RESQUE'
        assert.instanceOf resque, Test::Resque
        yield return
  describe '#fullQueueName', ->
    it 'should get full queue name', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @module Test
        Test::Resque.initialize()
        resque = Test::Resque.new 'TEST_RESQUE'
        queueName = resque.fullQueueName 'TEST'
        assert.equal queueName, 'Test|>TEST'
        yield return
  describe '#create', ->
    it 'should create new queue', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @module Test
          @public @async ensureQueue: Function,
            default: (asQueueName, anConcurrency) ->
              @getData().data[asQueueName] = name: asQueueName, concurrency: anConcurrency
              yield return @getData().data[asQueueName]
        Test::Resque.initialize()
        resque = Test::Resque.new 'TEST_RESQUE', data: {}
        queue = yield resque.create 'TEST_QUEUE', 4
        assert.propertyVal queue, 'name', 'TEST_QUEUE'
        assert.propertyVal queue, 'concurrency', 4
        assert.propertyVal queue, 'resque', resque
        yield return
