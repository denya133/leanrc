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
