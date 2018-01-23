EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'DelayableMixin', ->
  describe '#_delayJob', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should put job into delayed queue', ->
      co ->
        KEY = 'TEST_DELAYABLE_MIXIN_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        Test::Resque.initialize()
        class Test::Test extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::DelayableMixin
          @module Test
        Test::Test.initialize()
        facade.registerProxy Test::Resque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        yield resque.create LeanRC::DELAYED_JOBS_QUEUE, 4
        delayJobSymbol = Test::Test.classMethods['_delayJob']?.pointer
        assert.isTrue delayJobSymbol?
        DELAY_UNTIL = Date.now()
        DATA = {}
        options =
          queue: LeanRC::DELAYED_JOBS_QUEUE
          delayUntil: DELAY_UNTIL
        yield Test::Test[delayJobSymbol] facade, DATA, options
        rawQueue = resque[Symbol.for '~delayedJobs']['Test|>delayed_jobs']
        [ scriptData ] = rawQueue
        assert.deepEqual scriptData,
          queueName: 'Test|>delayed_jobs'
          data: scriptName: 'DelayedJobScript', data: DATA
          delayUntil: DELAY_UNTIL
          status: 'scheduled'
          lockLifetime: 5000
          lockLimit: 2
        yield return
  describe '.delay', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get delayed function wrapper', ->
      co ->
        KEY = 'TEST_DELAYABLE_MIXIN_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        Test::Resque.initialize()
        class Test::Test extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::DelayableMixin
          @module Test
          @public @static test: Function, { default: -> }
        Test::Test.initialize()
        facade.registerProxy Test::Resque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        yield resque.create LeanRC::DELAYED_JOBS_QUEUE, 4
        DELAY_UNTIL = Date.now()
        yield Test::Test.delay facade,
          queue: LeanRC::DELAYED_JOBS_QUEUE
          delayUntil: DELAY_UNTIL
        .test 'ARG_1', 'ARG_2', 'ARG_3'
        rawQueue = resque[Symbol.for '~delayedJobs']['Test|>delayed_jobs']
        [ scriptData ] = rawQueue
        assert.deepEqual scriptData,
          queueName: 'Test|>delayed_jobs'
          data:
            scriptName: 'DelayedJobScript'
            data:
              moduleName: 'Test'
              replica: {class: 'Test', type: 'class'}
              methodName: 'test'
              args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
              opts:
                queue: LeanRC::DELAYED_JOBS_QUEUE
                delayUntil: DELAY_UNTIL
          delayUntil: DELAY_UNTIL
          status: 'scheduled'
          lockLifetime: 5000
          lockLimit: 2
        yield return
  describe '#delay', ->
    facade = null
    afterEach ->
      facade?.remove?()
    it 'should get delayed function wrapper', ->
      co ->
        KEY = 'TEST_DELAYABLE_MIXIN_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        Test::Resque.initialize()
        class Test::Test extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::DelayableMixin
          @module Test
          @public test: Function, { default: -> }
        Test::Test.initialize()
        facade.registerProxy Test::Resque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        yield resque.create LeanRC::DELAYED_JOBS_QUEUE, 4
        DELAY_UNTIL = Date.now()
        yield Test::Test.new().delay facade,
          queue: LeanRC::DELAYED_JOBS_QUEUE
          delayUntil: DELAY_UNTIL
        .test 'ARG_1', 'ARG_2', 'ARG_3'
        rawQueue = resque[Symbol.for '~delayedJobs']['Test|>delayed_jobs']
        [ scriptData ] = rawQueue
        assert.deepEqual scriptData,
          queueName: 'Test|>delayed_jobs'
          data:
            scriptName: 'DelayedJobScript'
            data:
              moduleName: 'Test'
              replica: {class: 'Test', type: 'instance'}
              methodName: 'test'
              args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
              opts:
                queue: LeanRC::DELAYED_JOBS_QUEUE
                delayUntil: DELAY_UNTIL
          delayUntil: DELAY_UNTIL
          status: 'scheduled'
          lockLifetime: 5000
          lockLimit: 2
        yield return
