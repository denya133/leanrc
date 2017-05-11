EventEmitter  = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'MemoryResqueExecutor', ->
  describe '.new', ->
    it 'should create new memory resque executor', ->
      co ->
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        executor = LeanRC::MemoryResqueExecutor.new executorName, viewComponent
        assert.instanceOf executor, LeanRC::MemoryResqueExecutor
        yield return
  describe '#listNotificationInterests', ->
    it 'should check notification interests list', ->
      co ->
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        executor = LeanRC::MemoryResqueExecutor.new executorName, viewComponent
        assert.deepEqual executor.listNotificationInterests(), [
          LeanRC::JOB_RESULT, LeanRC::START_RESQUE
        ]
        yield return
  describe '#stop', ->
    it 'should stop executor', ->
      co ->
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        executor = LeanRC::MemoryResqueExecutor.new executorName, viewComponent
        executor.stop()
        executorSymbols = Object.getOwnPropertySymbols LeanRC::MemoryResqueExecutor::
        stoppedSymbol = _.find executorSymbols, (item) ->
          item.toString() is 'Symbol(_isStopped)'
        assert.isTrue executor[stoppedSymbol]
        yield return
  describe '#onRemove', ->
    it 'should handle remove event', ->
      co ->
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        executor = LeanRC::MemoryResqueExecutor.new executorName, viewComponent
        executor.onRemove()
        executorSymbols = Object.getOwnPropertySymbols LeanRC::MemoryResqueExecutor::
        stoppedSymbol = _.find executorSymbols, (item) ->
          item.toString() is 'Symbol(_isStopped)'
        assert.isTrue executor[stoppedSymbol]
        yield return
  describe '#define', ->
    it 'should define processor (success)', ->
      co ->
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        executor = LeanRC::MemoryResqueExecutor.new executorName, viewComponent
        executorSymbols = Object.getOwnPropertySymbols LeanRC::MemoryResqueExecutor::
        definedProcessorsSymbol = _.find executorSymbols, (item) ->
          item.toString() is 'Symbol(_definedProcessors)'
        concurrencyCountSymbol = _.find executorSymbols, (item) ->
          item.toString() is 'Symbol(_concurrencyCount)'
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
        executor = LeanRC::MemoryResqueExecutor.new executorName, viewComponent
        executorSymbols = Object.getOwnPropertySymbols LeanRC::MemoryResqueExecutor::
        definedProcessorsSymbol = _.find executorSymbols, (item) ->
          item.toString() is 'Symbol(_definedProcessors)'
        concurrencyCountSymbol = _.find executorSymbols, (item) ->
          item.toString() is 'Symbol(_concurrencyCount)'
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
        class Test extends LeanRC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class Test::Resque extends LeanRC::Resque
          @inheritProtected()
          @include LeanRC::MemoryResqueMixin
          @module Test
        Test::Resque.initialize()
        class Test::MemoryResqueExecutor extends LeanRC::MemoryResqueExecutor
          @inheritProtected()
          @module Test
        Test::MemoryResqueExecutor.initialize()
        facade.registerProxy Test::Resque.new LeanRC::RESQUE
        resque = facade.retrieveProxy LeanRC::RESQUE
        resque.create 'TEST_QUEUE_1', 4
        resque.create 'TEST_QUEUE_2', 4
        executorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        executor = Test::MemoryResqueExecutor.new executorName, viewComponent
        executorSymbols = Object.getOwnPropertySymbols LeanRC::MemoryResqueExecutor::
        definedProcessorsSymbol = _.find executorSymbols, (item) ->
          item.toString() is 'Symbol(_definedProcessors)'
        concurrencyCountSymbol = _.find executorSymbols, (item) ->
          item.toString() is 'Symbol(_concurrencyCount)'
        resqueSymbol = _.find executorSymbols, (item) ->
          item.toString() is 'Symbol(_resque)'
        executor.initializeNotifier KEY
        executor.setViewComponent new EventEmitter()
        executor[definedProcessorsSymbol] = {}
        executor[concurrencyCountSymbol] = {}
        executor[resqueSymbol] = resque
        yield executor.defineProcessors()
        assert.property executor[definedProcessorsSymbol], 'TEST_QUEUE_1'
        assert.property executor[definedProcessorsSymbol], 'TEST_QUEUE_2'
        yield return
  ###
  describe '#getMediatorName', ->
    it 'should get mediator name', ->
      mediatorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
      viewComponent = { id: 'view-component' }
      mediator = Mediator.new mediatorName, viewComponent
      expect mediator.getMediatorName()
      .to.equal mediatorName
  describe '#getViewComponent', ->
    it 'should get mediator view component', ->
      mediatorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
      viewComponent = { id: 'view-component' }
      mediator = Mediator.new mediatorName, viewComponent
      expect mediator.getViewComponent()
      .to.equal viewComponent
  describe '#listNotificationInterests', ->
    it 'should get mediator motification interests list', ->
      class TestMediator extends Mediator
        @inheritProtected()
        @public listNotificationInterests: Function,
          default: -> [ 'TEST1' , 'TEST2', 'TEST3' ]
      mediatorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
      viewComponent = { id: 'view-component' }
      mediator = TestMediator.new mediatorName, viewComponent
      expect mediator.listNotificationInterests()
      .to.eql [ 'TEST1' , 'TEST2', 'TEST3' ]
  describe '#handleNotification', ->
    it 'should call handleNotification', ->
      expect ->
        mediatorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        mediator = Mediator.new mediatorName, viewComponent
        handleNotification = sinon.spy mediator, 'handleNotification'
        mediator.handleNotification()
        assert handleNotification.called
      .to.not.throw Error
  describe '#onRegister', ->
    it 'should call onRegister', ->
      expect ->
        mediatorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        mediator = Mediator.new mediatorName, viewComponent
        onRegister = sinon.spy mediator, 'onRegister'
        mediator.onRegister()
        assert onRegister.called
      .to.not.throw Error
  describe '#onRemove', ->
    it 'should call onRemove', ->
      expect ->
        mediatorName = 'TEST_MEMORY_RESQUE_EXECUTOR'
        viewComponent = { id: 'view-component' }
        mediator = Mediator.new mediatorName, viewComponent
        onRemove = sinon.spy mediator, 'onRemove'
        mediator.onRemove()
        assert onRemove.called
      .to.not.throw Error
  ###
