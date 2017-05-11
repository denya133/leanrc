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
