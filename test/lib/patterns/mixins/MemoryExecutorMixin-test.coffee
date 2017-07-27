EventEmitter  = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'MemoryExecutorMixin', ->
  describe '.new', ->
    it 'should create new memory resque executor', ->
      co ->
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
        MemoryResqueExecutor.initialize()
        executor = MemoryResqueExecutor.new executorName, viewComponent
        assert.instanceOf executor, MemoryResqueExecutor
        yield return
  describe '#listNotificationInterests', ->
    it 'should check notification interests list', ->
      co ->
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
        MemoryResqueExecutor.initialize()
        executor = MemoryResqueExecutor.new executorName, viewComponent
        assert.deepEqual executor.listNotificationInterests(), [
          LeanRC::JOB_RESULT, LeanRC::START_RESQUE
        ]
        yield return
  describe '#stop', ->
    it 'should stop executor', ->
      co ->
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
        MemoryResqueExecutor.initialize()
        executor = MemoryResqueExecutor.new executorName, viewComponent
        executor.stop()
        stoppedSymbol = MemoryResqueExecutor
          .metaObject
          .getGroup 'instanceVariables'
          ._isStopped
          .pointer
        assert.isTrue executor[stoppedSymbol]
        yield return
  describe '#onRemove', ->
    it 'should handle remove event', ->
      co ->
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
        MemoryResqueExecutor.initialize()
        executor = MemoryResqueExecutor.new executorName, viewComponent
        executor.onRemove()
        stoppedSymbol = MemoryResqueExecutor
          .metaObject
          .getGroup 'instanceVariables'
          ._isStopped
          .pointer
        assert.isTrue executor[stoppedSymbol]
        yield return
  describe '#define', ->
    it 'should define processor (success)', ->
      co ->
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
        MemoryResqueExecutor.initialize()
        executor = MemoryResqueExecutor.new executorName, viewComponent
        executorSymbols = MemoryResqueExecutor
          .metaObject
          .getGroup 'instanceVariables'
        definedProcessorsSymbol = executorSymbols._definedProcessors.pointer
        concurrencyCountSymbol = executorSymbols._concurrencyCount.pointer
        executor[definedProcessorsSymbol] = {}
        executor[concurrencyCountSymbol] = {}
        QUEUE_NAME = 'TEST_QUEUE'
        concurrency = 4
        testTrigger = new EventEmitter
        executor.define QUEUE_NAME, { concurrency }, (job, done) ->
          assert job
          testTrigger.once 'DONE', (options) -> done options
        processorData = executor[definedProcessorsSymbol][QUEUE_NAME]
        assert.equal processorData.concurrency, concurrency
        { listener, concurrency: processorConcurrency } = processorData
        assert.equal processorConcurrency, concurrency
        job = status: 'scheduled'
        listener job
        assert.equal executor[concurrencyCountSymbol][QUEUE_NAME], 1
        assert.propertyVal job, 'status', 'running'
        assert.isDefined job.startedAt
        promise = LeanRC::Promise.new (resolve) ->
          testTrigger.once 'DONE', resolve
        testTrigger.emit 'DONE'
        yield promise
        assert.equal executor[concurrencyCountSymbol][QUEUE_NAME], 0
        assert.propertyVal job, 'status', 'completed'
        yield return
    it 'should define processor (fail)', ->
      co ->
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
        MemoryResqueExecutor.initialize()
        executor = MemoryResqueExecutor.new executorName, viewComponent
        executorSymbols = MemoryResqueExecutor
          .metaObject
          .getGroup 'instanceVariables'
        definedProcessorsSymbol = executorSymbols._definedProcessors.pointer
        concurrencyCountSymbol = executorSymbols._concurrencyCount.pointer
        executor[definedProcessorsSymbol] = {}
        executor[concurrencyCountSymbol] = {}
        QUEUE_NAME = 'TEST_QUEUE'
        concurrency = 4
        testTrigger = new EventEmitter
        executor.define QUEUE_NAME, { concurrency }, (job, done) ->
          assert job
          testTrigger.once 'DONE', (options) -> done options
        processorData = executor[definedProcessorsSymbol][QUEUE_NAME]
        assert.equal processorData.concurrency, concurrency
        { listener, concurrency: processorConcurrency } = processorData
        assert.equal processorConcurrency, concurrency
        job = status: 'scheduled'
        listener job
        assert.equal executor[concurrencyCountSymbol][QUEUE_NAME], 1
        assert.propertyVal job, 'status', 'running'
        assert.isDefined job.startedAt
        promise = LeanRC::Promise.new (resolve) ->
          testTrigger.once 'DONE', resolve
        testTrigger.emit 'DONE', error: 'error'
        yield promise
        assert.equal executor[concurrencyCountSymbol][QUEUE_NAME], 0
        assert.propertyVal job, 'status', 'failed'
        assert.deepEqual job.reason, error: 'error'
        yield return
  describe '#defineProcessors', ->
    it 'should define processors', ->
      co ->
        KEY = 'TEST_MEMORY_RESQUE_EXECUTOR_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        TestResque.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
        MemoryResqueExecutor.initialize()
        facade.registerProxy TestResque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        resque.create 'TEST_QUEUE_1', 4
        resque.create 'TEST_QUEUE_2', 4
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        executor = MemoryResqueExecutor.new executorName, viewComponent
        executorSymbols = MemoryResqueExecutor
          .metaObject
          .getGroup 'instanceVariables'
        definedProcessorsSymbol = executorSymbols._definedProcessors.pointer
        concurrencyCountSymbol = executorSymbols._concurrencyCount.pointer
        resqueSymbol = executorSymbols._resque.pointer
        executor.initializeNotifier KEY
        executor.setViewComponent new EventEmitter()
        executor[definedProcessorsSymbol] = {}
        executor[concurrencyCountSymbol] = {}
        executor[resqueSymbol] = resque
        yield executor.defineProcessors()
        assert.property executor[definedProcessorsSymbol], 'TEST_QUEUE_1'
        assert.property executor[definedProcessorsSymbol], 'TEST_QUEUE_2'
        facade.remove()
        yield return
  describe '#reDefineProcessors', ->
    it 'should redefine processors', ->
      co ->
        KEY = 'TEST_MEMORY_RESQUE_EXECUTOR_009'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        TestResque.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
        MemoryResqueExecutor.initialize()
        facade.registerProxy TestResque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        resque.create 'TEST_QUEUE_1', 4
        resque.create 'TEST_QUEUE_2', 4
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        executor = MemoryResqueExecutor.new executorName, viewComponent
        executorSymbols = MemoryResqueExecutor
          .metaObject
          .getGroup 'instanceVariables'
        definedProcessorsSymbol = executorSymbols._definedProcessors.pointer
        concurrencyCountSymbol = executorSymbols._concurrencyCount.pointer
        resqueSymbol = executorSymbols._resque.pointer
        executor.initializeNotifier KEY
        executor.setViewComponent new EventEmitter()
        executor[definedProcessorsSymbol] = {}
        executor[concurrencyCountSymbol] = {}
        executor[resqueSymbol] = resque
        yield executor.defineProcessors()
        assert.property executor[definedProcessorsSymbol], 'TEST_QUEUE_1'
        assert.property executor[definedProcessorsSymbol], 'TEST_QUEUE_2'
        delete executor[definedProcessorsSymbol]
        yield executor.reDefineProcessors()
        assert.property executor[definedProcessorsSymbol], 'TEST_QUEUE_1'
        assert.property executor[definedProcessorsSymbol], 'TEST_QUEUE_2'
        facade.remove()
        yield return
  describe '#onRegister', ->
    it 'should setup executor on register', ->
      co ->
        KEY = 'TEST_MEMORY_RESQUE_EXECUTOR_002'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        TestResque.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
          @public @async defineProcessors: Function,
            default: (args...) ->
              yield @super args...
              trigger.emit 'PROCESSORS_DEFINED'
              yield return
        MemoryResqueExecutor.initialize()
        facade.registerProxy TestResque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        resque.create 'TEST_QUEUE_1', 4
        resque.create 'TEST_QUEUE_2', 4
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        executor = MemoryResqueExecutor.new executorName, viewComponent
        executorSymbols = MemoryResqueExecutor
          .metaObject
          .getGroup 'instanceVariables'
        definedProcessorsSymbol = executorSymbols._definedProcessors.pointer
        promise = LeanRC::Promise.new (resolve) ->
          trigger.once 'PROCESSORS_DEFINED', resolve
        facade.registerMediator executor
        yield promise
        assert.property executor[definedProcessorsSymbol], 'TEST_QUEUE_1'
        assert.property executor[definedProcessorsSymbol], 'TEST_QUEUE_2'
        facade.remove()
        yield return
  describe '#recursion', ->
    it 'should recursively call cycle part', ->
      co ->
        KEY = 'TEST_MEMORY_RESQUE_EXECUTOR_004'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        test = null
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        TestResque.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
          @public @async defineProcessors: Function,
            default: (args...) ->
              yield @super args...
              trigger.emit 'PROCESSORS_DEFINED'
              yield return
          @public @async cyclePart: Function,
            default: ->
              test = yes
              trigger.emit 'CYCLE_PART'
              yield return
        MemoryResqueExecutor.initialize()
        facade.registerProxy TestResque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        resque.create LeanRC::DELAYED_JOBS_QUEUE, 4
        executor = MemoryResqueExecutor.new LeanRC::RESQUE_EXECUTOR
        executorSymbols = MemoryResqueExecutor
          .metaObject
          .getGroup 'instanceVariables'
        definedProcessorsSymbol = executorSymbols._definedProcessors.pointer
        isStoppedSymbol = executorSymbols._isStopped.pointer
        promise = LeanRC::Promise.new (resolve) ->
          trigger.once 'PROCESSORS_DEFINED', resolve
        facade.registerMediator executor
        yield promise
        promise = LeanRC::Promise.new (resolve) ->
          trigger.once 'CYCLE_PART', resolve
        executor[isStoppedSymbol] = no
        yield executor.recursion()
        yield promise
        assert.isNotNull test
        facade.remove()
        yield return
  describe '#start', ->
    it 'should call recursion', ->
      co ->
        KEY = 'TEST_MEMORY_RESQUE_EXECUTOR_005'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        test = null
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        TestResque.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
          @public @async defineProcessors: Function,
            default: (args...) ->
              yield @super args...
              trigger.emit 'PROCESSORS_DEFINED'
              yield return
          @public @async cyclePart: Function,
            default: ->
              test = yes
              trigger.emit 'CYCLE_PART'
              yield return
        MemoryResqueExecutor.initialize()
        facade.registerProxy TestResque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        resque.create LeanRC::DELAYED_JOBS_QUEUE, 4
        executor = MemoryResqueExecutor.new LeanRC::RESQUE_EXECUTOR
        executorSymbols = MemoryResqueExecutor
          .metaObject
          .getGroup 'instanceVariables'
        definedProcessorsSymbol = executorSymbols._definedProcessors.pointer
        promise = LeanRC::Promise.new (resolve) ->
          trigger.once 'PROCESSORS_DEFINED', resolve
        facade.registerMediator executor
        yield promise
        promise = LeanRC::Promise.new (resolve) ->
          trigger.once 'CYCLE_PART', resolve
        yield executor.start()
        yield promise
        assert.isNotNull test
        facade.remove()
        yield return
  describe '#handleNotification', ->
    it 'should start resque', ->
      co ->
        KEY = 'TEST_MEMORY_RESQUE_EXECUTOR_006'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        test = null
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        TestResque.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
          @public @async start: Function,
            default: ->
              test = yes
              trigger.emit 'CYCLE_PART'
              yield return
        MemoryResqueExecutor.initialize()
        facade.registerProxy TestResque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        resque.create LeanRC::DELAYED_JOBS_QUEUE, 4
        facade.registerMediator MemoryResqueExecutor.new LeanRC::RESQUE_EXECUTOR
        executor = facade.retrieveMediator LeanRC::RESQUE_EXECUTOR
        promise = LeanRC::Promise.new (resolve) ->
          trigger.once 'CYCLE_PART', resolve
        facade.sendNotification LeanRC::START_RESQUE
        yield promise
        assert.isNotNull test
        facade.remove()
        yield return
    it 'should get result', ->
      co ->
        KEY = 'TEST_MEMORY_RESQUE_EXECUTOR_007'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        TestResque.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
        MemoryResqueExecutor.initialize()
        facade.registerProxy TestResque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        resque.create LeanRC::DELAYED_JOBS_QUEUE, 4
        facade.registerMediator MemoryResqueExecutor.new LeanRC::RESQUE_EXECUTOR
        executor = facade.retrieveMediator LeanRC::RESQUE_EXECUTOR
        type = 'TEST_TYPE'
        promise = LeanRC::Promise.new (resolve) ->
          executor.getViewComponent().once type, resolve
        body = test: 'test'
        facade.sendNotification LeanRC::JOB_RESULT, body, type
        data = yield promise
        assert.deepEqual data, body
        facade.remove()
        yield return
  describe '#cyclePart', ->
    it 'should start cycle part', ->
      co ->
        KEY = 'TEST_MEMORY_RESQUE_EXECUTOR_008'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        TestResque.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
        MemoryResqueExecutor.initialize()
        class TestScript extends LeanRC::Script
          @inheritProtected()
          @module Test
          @do (body) ->
            trigger.emit 'CYCLE_PART', body
            yield return
        TestScript.initialize()
        facade.registerCommand 'TEST_SCRIPT', TestScript
        facade.registerProxy TestResque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        yield resque.create LeanRC::DELAYED_JOBS_QUEUE, 4
        queue = yield resque.get LeanRC::DELAYED_JOBS_QUEUE
        facade.registerMediator MemoryResqueExecutor.new LeanRC::RESQUE_EXECUTOR
        executor = facade.retrieveMediator LeanRC::RESQUE_EXECUTOR
        promise = LeanRC::Promise.new (resolve) ->
          trigger.once 'CYCLE_PART', resolve
        DELAY_UNTIL = Date.now() + 1000
        body = arg1: 'ARG_1', arg2: 'ARG_2', arg3: 'ARG_3'
        yield queue.push 'TEST_SCRIPT', body, DELAY_UNTIL
        facade.sendNotification LeanRC::START_RESQUE
        data = yield promise
        assert.deepEqual data, body
        facade.remove()
        yield return
  describe '#fullQueueName', ->
    it 'should get full queue name', ->
      co ->
        KEY = 'TEST_MEMORY_RESQUE_EXECUTOR_010'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestResque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        TestResque.initialize()
        class MemoryResqueExecutor extends LeanRC::Mediator
          @inheritProtected()
          @include LeanRC::MemoryExecutorMixin
          @module Test
        MemoryResqueExecutor.initialize()
        facade.registerProxy TestResque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        resque.create 'TEST_QUEUE_1', 4
        resque.create 'TEST_QUEUE_2', 4
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        executor = MemoryResqueExecutor.new executorName, viewComponent
        facade.registerMediator executor
        fullQueueName = executor.fullQueueName 'TEST_QUEUE_1'
        assert.equal fullQueueName, 'Test|>TEST_QUEUE_1'
        facade.remove()
        yield return
