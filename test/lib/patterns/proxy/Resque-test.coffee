{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'Resque', ->
  describe '.new', ->
    it 'should create resque instance', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @module Test
        TestResque.initialize()
        resque = TestResque.new 'TEST_RESQUE'
        assert.instanceOf resque, TestResque
        yield return
  describe '#fullQueueName', ->
    it 'should get full queue name', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @module Test
        TestResque.initialize()
        resque = TestResque.new 'TEST_RESQUE'
        queueName = resque.fullQueueName 'TEST'
        assert.equal queueName, 'Test|>TEST'
        yield return
  describe '#create', ->
    it 'should create new queue', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
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
        TestResque.initialize()
        resque = TestResque.new 'TEST_RESQUE', data: []
        queue = yield resque.create 'TEST_QUEUE', 4
        assert.propertyVal queue, 'name', 'TEST_QUEUE'
        assert.propertyVal queue, 'concurrency', 4
        assert.propertyVal queue, 'resque', resque
        yield return
  describe '#all', ->
    it 'should get all queues', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
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
        TestResque.initialize()
        resque = TestResque.new 'TEST_RESQUE', data: []
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
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
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
        TestResque.initialize()
        resque = TestResque.new 'TEST_RESQUE', data: []
        yield resque.create 'TEST_QUEUE_1', 4
        queue = yield resque.get 'TEST_QUEUE_1'
        assert.propertyVal queue, 'name', 'TEST_QUEUE_1'
        assert.propertyVal queue, 'concurrency', 4
        yield return
  describe '#remove', ->
    it 'should remove single queue', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
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
          @public @async removeQueue: Function,
            default: (asQueueName) ->
              _.remove @getData().data, name: asQueueName
              yield return
        TestResque.initialize()
        resque = TestResque.new 'TEST_RESQUE', data: []
        yield resque.create 'TEST_QUEUE_1', 4
        queue = yield resque.get 'TEST_QUEUE_1'
        assert.isDefined queue
        yield resque.remove 'TEST_QUEUE_1'
        queue = yield resque.get 'TEST_QUEUE_1'
        assert.isUndefined queue
        yield return
  describe '#update', ->
    it 'should update single queue', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
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
        TestResque.initialize()
        resque = TestResque.new 'TEST_RESQUE', data: []
        yield resque.create 'TEST_QUEUE_1', 4
        queue = yield resque.get 'TEST_QUEUE_1'
        assert.propertyVal queue, 'concurrency', 4
        yield resque.update 'TEST_QUEUE_1', 3
        queue = yield resque.get 'TEST_QUEUE_1'
        assert.propertyVal queue, 'concurrency', 3
        yield return
  describe '#delay', ->
    facade = null
    afterEach -> facade?.remove?()
    it 'should put delayed procedure into queue', ->
      co ->
        MULTITON_KEY = 'TEST_RESQUE_001'
        facade = LeanRC::Facade.getInstance MULTITON_KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @module Test
          @public jobs: Object, { default: {} }
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
          @public @async pushJob: Function,
            default: (name, scriptName, data, delayUntil) ->
              id = LeanRC::Utils.uuid.v4()
              @jobs[id] = { name, scriptName, data, delayUntil }
              yield return id
          @public init: Function,
            default: (args...) ->
              @super args...
              @jobs = {}
        TestResque.initialize()
        resque = TestResque.new 'TEST_RESQUE', data: []
        facade.registerProxy resque
        yield resque.create 'TEST_QUEUE_1', 4
        id = yield resque.delay 'TEST_QUEUE_1', 'TestScript', { data: 'data' }, 100
        assert.deepEqual resque.jobs[id],
          name: 'TEST_QUEUE_1'
          scriptName: 'TestScript'
          data: { data: 'data' }
          delayUntil: 100
        yield return
    it 'should put delayed procedure into cache', ->
      co ->
        MULTITON_KEY = 'TEST_RESQUE_001|>123456-5432-234-5432'
        facade = LeanRC::Facade.getInstance MULTITON_KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
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
        TestResque.initialize()
        resque = TestResque.new 'TEST_RESQUE', data: []
        facade.registerProxy resque
        yield resque.create 'TEST_QUEUE_1', 4
        id = yield resque.delay 'TEST_QUEUE_1', 'TestScript', { data: 'data' }, 100
        job = _.find resque.tmpJobs, { id }
        assert.deepEqual job,
          id: id
          queueName: 'TEST_QUEUE_1'
          scriptName: 'TestScript'
          data: { data: 'data' }
          delay: 100
        yield return
  describe '#getDelayed', ->
    facade = null
    afterEach -> facade?.remove?()
    it 'should get delayed jobs from cache', ->
      co ->
        MULTITON_KEY = 'TEST_RESQUE_001|>123456-5432-234-5432'
        facade = LeanRC::Facade.getInstance MULTITON_KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
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
        TestResque.initialize()
        resque = TestResque.new 'TEST_RESQUE', data: []
        facade.registerProxy resque
        yield resque.create 'TEST_QUEUE_1', 4
        yield resque.delay 'TEST_QUEUE_1', 'TestScript', { data: 'data1' }, 100
        yield resque.delay 'TEST_QUEUE_1', 'TestScript', { data: 'data2' }, 100
        yield resque.delay 'TEST_QUEUE_1', 'TestScript', { data: 'data3' }, 100
        yield resque.delay 'TEST_QUEUE_1', 'TestScript', { data: 'data4' }, 100
        delayeds = yield resque.getDelayed()
        assert.lengthOf delayeds, 4
        for delayed, index in delayeds
          assert.isDefined delayed
          assert.isNotNull delayed
          assert.include delayed,
            queueName: 'TEST_QUEUE_1',
            scriptName: 'TestScript',
            delay: 100
          assert.deepEqual delayed.data, data: "data#{index + 1}"
        yield return
