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
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        class TestClass extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @public @static test: Function,
            default: -> return
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @initialize()
        class TestTest extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::DelayableMixin
          @module Test
          @initialize()
        facade.registerProxy TestResque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        yield resque.create LeanRC::DELAYED_JOBS_QUEUE, 4
        delayJobSymbol = TestTest.classMethods['_delayJob']?.pointer
        assert.isTrue delayJobSymbol?
        DELAY_UNTIL = Date.now()
        options =
          queue: LeanRC::DELAYED_JOBS_QUEUE
          delayUntil: DELAY_UNTIL
        DATA =
          moduleName: 'Test'
          replica: yield TestClass.constructor.replicateObject TestClass
          methodName: 'test'
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          opts: options
        yield TestTest[delayJobSymbol] facade, DATA, options
        rawQueue = resque[Symbol.for '~jobs']['Test|>delayed_jobs']
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
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @initialize()
        class TestTest extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::DelayableMixin
          @module Test
          @public @static test: Function, { default: -> }
          @initialize()
        facade.registerProxy TestResque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        yield resque.create LeanRC::DELAYED_JOBS_QUEUE, 4
        DELAY_UNTIL = Date.now()
        yield TestTest.delay facade,
          queue: LeanRC::DELAYED_JOBS_QUEUE
          delayUntil: DELAY_UNTIL
        .test 'ARG_1', 'ARG_2', 'ARG_3'
        rawQueue = resque[Symbol.for '~jobs']['Test|>delayed_jobs']
        [ scriptData ] = rawQueue
        assert.deepEqual scriptData,
          queueName: 'Test|>delayed_jobs'
          data:
            scriptName: 'DelayedJobScript'
            data:
              moduleName: 'Test'
              replica: {class: 'TestTest', type: 'class'}
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
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
          @initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
          @initialize()
        class TestTest extends LeanRC::CoreObject
          @inheritProtected()
          @include LeanRC::DelayableMixin
          @module Test
          @public test: Function, { default: -> }
          @initialize()
        facade.registerProxy TestResque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        yield resque.create LeanRC::DELAYED_JOBS_QUEUE, 4
        DELAY_UNTIL = Date.now()
        yield TestTest.new().delay facade,
          queue: LeanRC::DELAYED_JOBS_QUEUE
          delayUntil: DELAY_UNTIL
        .test 'ARG_1', 'ARG_2', 'ARG_3'
        rawQueue = resque[Symbol.for '~jobs']['Test|>delayed_jobs']
        [ scriptData ] = rawQueue
        assert.deepEqual scriptData,
          queueName: 'Test|>delayed_jobs'
          data:
            scriptName: 'DelayedJobScript'
            data:
              moduleName: 'Test'
              replica: {class: 'TestTest', type: 'instance'}
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
