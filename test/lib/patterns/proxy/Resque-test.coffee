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
              queue = _.find @getData().data, name: asQueueName
              if queue?
                queue.concurrency = anConcurrency
              else
                queue = name: asQueueName, concurrency: anConcurrency
                @getData().data.push queue
              yield return queue
        Test::Resque.initialize()
        resque = Test::Resque.new 'TEST_RESQUE', data: []
        queue = yield resque.create 'TEST_QUEUE', 4
        assert.propertyVal queue, 'name', 'TEST_QUEUE'
        assert.propertyVal queue, 'concurrency', 4
        assert.propertyVal queue, 'resque', resque
        yield return
  describe '#all', ->
    it 'should get all queues', ->
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
              queue = _.find @getData().data, name: asQueueName
              if queue?
                queue.concurrency = anConcurrency
              else
                queue = name: asQueueName, concurrency: anConcurrency
                @getData().data.push queue
              yield return queue
          @public @async allQueues: Function,
            default: -> yield return @getData().data
        Test::Resque.initialize()
        resque = Test::Resque.new 'TEST_RESQUE', data: []
        yield resque.create 'TEST_QUEUE_1', 4
        yield resque.create 'TEST_QUEUE_2', 1
        yield resque.create 'TEST_QUEUE_3', 2
        yield resque.create 'TEST_QUEUE_4', 3
        queues = yield resque.all()
        assert.propertyVal queues[0], 'name', 'TEST_QUEUE_1'
        assert.propertyVal queues[0], 'concurrency', 4
        assert.propertyVal queues[1], 'name', 'TEST_QUEUE_2'
        assert.propertyVal queues[1], 'concurrency', 1
        assert.propertyVal queues[2], 'name', 'TEST_QUEUE_3'
        assert.propertyVal queues[2], 'concurrency', 2
        assert.propertyVal queues[3], 'name', 'TEST_QUEUE_4'
        assert.propertyVal queues[3], 'concurrency', 3
        yield return
  describe '#get', ->
    it 'should get single queue', ->
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
              queue = _.find @getData().data, name: asQueueName
              if queue?
                queue.concurrency = anConcurrency
              else
                queue = name: asQueueName, concurrency: anConcurrency
                @getData().data.push queue
              yield return queue
          @public @async getQueue: Function,
            default: (asQueueName) ->
              yield return _.find @getData().data, name: asQueueName
        Test::Resque.initialize()
        resque = Test::Resque.new 'TEST_RESQUE', data: []
        yield resque.create 'TEST_QUEUE_1', 4
        queue = yield resque.get 'TEST_QUEUE_1'
        assert.propertyVal queue, 'name', 'TEST_QUEUE_1'
        assert.propertyVal queue, 'concurrency', 4
        yield return
