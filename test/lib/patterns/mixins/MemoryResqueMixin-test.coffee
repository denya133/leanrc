{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
RC = require 'RC'
LeanRC = require.main.require 'lib'
{ co } = RC::Utils


describe 'MemoryResqueMixin', ->
  describe '.new', ->
    it 'should create resque instance', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        Test::Resque.initialize()
        resque = Test::Resque.new 'TEST_RESQUE'
        assert.instanceOf resque, Test::Resque
        yield return
  describe '#onRegister', ->
    it 'should register resque instance', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        Test::Resque.initialize()
        resque = Test::Resque.new 'TEST_RESQUE'
        resque.onRegister()
        assert.deepEqual resque[Symbol.for '~delayedJobs'], {}
        assert.deepEqual resque[Symbol.for '~delayedQueues'], {}
        yield return
  describe '#onRemove', ->
    it 'should unregister resque instance', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        Test::Resque.initialize()
        resque = Test::Resque.new 'TEST_RESQUE'
        resque.onRegister()
        assert.deepEqual resque[Symbol.for '~delayedJobs'], {}
        assert.deepEqual resque[Symbol.for '~delayedQueues'], {}
        resque.onRemove()
        assert.isUndefined resque[Symbol.for '~delayedJobs']
        assert.isUndefined resque[Symbol.for '~delayedQueues']
        yield return
  describe '#ensureQueue', ->
    it 'should create queue config', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        Test::Resque.initialize()
        resque = Test::Resque.new 'TEST_RESQUE'
        resque.onRegister()
        resque.ensureQueue 'TEST_QUEUE', 5
        queue = resque[Symbol.for '~delayedQueues']['Test|>TEST_QUEUE']
        assert.propertyVal queue, 'name', 'TEST_QUEUE'
        assert.propertyVal queue, 'concurrency', 5
        yield return
  describe '#getQueue', ->
    it 'should get queue', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        Test::Resque.initialize()
        resque = Test::Resque.new 'TEST_RESQUE'
        resque.onRegister()
        resque.ensureQueue 'TEST_QUEUE', 5
        queue = yield resque.getQueue 'TEST_QUEUE'
        assert.propertyVal queue, 'name', 'TEST_QUEUE'
        assert.propertyVal queue, 'concurrency', 5
        yield return
  describe '#removeQueue', ->
    it 'should remove queue', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        Test::Resque.initialize()
        resque = Test::Resque.new 'TEST_RESQUE'
        resque.onRegister()
        resque.ensureQueue 'TEST_QUEUE', 5
        queue = yield resque.getQueue 'TEST_QUEUE'
        assert.isDefined queue
        yield resque.removeQueue 'TEST_QUEUE'
        queue = yield resque.getQueue 'TEST_QUEUE'
        assert.isUndefined queue
        yield return
  describe '#allQueues', ->
    it 'should get all queues', ->
      co ->
        class Test extends RC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        Test::Resque.initialize()
        resque = Test::Resque.new 'TEST_RESQUE'
        resque.onRegister()
        resque.ensureQueue 'TEST_QUEUE_1', 1
        resque.ensureQueue 'TEST_QUEUE_2', 2
        resque.ensureQueue 'TEST_QUEUE_3', 3
        resque.ensureQueue 'TEST_QUEUE_4', 4
        resque.ensureQueue 'TEST_QUEUE_5', 5
        resque.ensureQueue 'TEST_QUEUE_6', 6
        queues = yield resque.allQueues()
        assert.lengthOf queues, 6
        assert.includeDeepMembers queues, [
          name: 'TEST_QUEUE_1', concurrency: 1
        ,
          name: 'TEST_QUEUE_2', concurrency: 2
        ,
          name: 'TEST_QUEUE_3', concurrency: 3
        ,
          name: 'TEST_QUEUE_4', concurrency: 4
        ,
          name: 'TEST_QUEUE_5', concurrency: 5
        ,
          name: 'TEST_QUEUE_6', concurrency: 6
        ]
        yield return
