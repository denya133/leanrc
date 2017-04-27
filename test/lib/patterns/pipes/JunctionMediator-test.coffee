{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
JunctionMediator = LeanRC::Pipes::JunctionMediator
Junction = LeanRC::Pipes::Junction
Pipe = LeanRC::Pipes::Pipe
Notification = LeanRC::Notification
PipeMessage = LeanRC::Pipes::PipeMessage

describe 'JunctionMediator', ->
  describe '.new', ->
    it 'should create new JunctionMediator instance', ->
      expect ->
        JunctionMediator.new()
      .to.not.throw Error
  describe '#listNotificationInterests', ->
    it 'should get acceptable notifications', ->
      expect ->
        mediator = JunctionMediator.new()
        assert.deepEqual mediator.listNotificationInterests(), [
          JunctionMediator.ACCEPT_INPUT_PIPE
          JunctionMediator.ACCEPT_OUTPUT_PIPE
          JunctionMediator.REMOVE_PIPE
        ], 'Acceptable notifications list is incorrect'
      .to.not.throw Error
  describe '#handleNotification', ->
    it 'should handle `LeanRC::JunctionMediator.ACCEPT_INPUT_PIPE` notification', ->
      expect ->
        MULTITON_KEY = 'TEST_JUNCTION_1'
        inputPipe = Pipe.new()
        junction = Junction.new()
        spyRegisterPipe = sinon.spy junction, 'registerPipe'
        spyAddPipeListener = sinon.spy junction, 'addPipeListener'
        mediator = JunctionMediator.new 'TEST_MEDIATOR', junction
        mediator.initializeNotifier MULTITON_KEY
        spySendNotification = sinon.spy mediator, 'sendNotification'
        notification = Notification.new JunctionMediator.ACCEPT_INPUT_PIPE, inputPipe, 'INPUT_PIPE'
        mediator.handleNotification notification
        assert.isTrue spyRegisterPipe.calledWith('INPUT_PIPE', Junction.INPUT, inputPipe), 'Junction::registerPipe did not called'
        assert.isTrue spyAddPipeListener.calledWith('INPUT_PIPE', mediator, mediator.handlePipeMessage), 'Junction::addPipeListener did not called'
        message = PipeMessage.new PipeMessage.NORMAL
        inputPipe.write message
        assert.isTrue spySendNotification.calledWith(PipeMessage.NORMAL, message), 'JunctionMediator::handlePipeMessage did not called'
      .to.not.throw Error
    it 'should handle `LeanRC::JunctionMediator.ACCEPT_OUTPUT_PIPE` notification', ->
      expect ->
        MULTITON_KEY = 'TEST_JUNCTION_2'
        finalNode = write: ->
        spyWrite = sinon.spy finalNode, 'write'
        outputPipe = Pipe.new finalNode
        junction = Junction.new()
        spyRegisterPipe = sinon.spy junction, 'registerPipe'
        mediator = JunctionMediator.new 'TEST_MEDIATOR', junction
        mediator.initializeNotifier MULTITON_KEY
        notification = Notification.new JunctionMediator.ACCEPT_OUTPUT_PIPE, outputPipe, 'OUTPUT_PIPE'
        mediator.handleNotification notification
        assert.isTrue spyRegisterPipe.calledWith('OUTPUT_PIPE', Junction.OUTPUT, outputPipe), 'Junction::registerPipe did not called'
        message = PipeMessage.new PipeMessage.NORMAL
        junction.sendMessage 'OUTPUT_PIPE', message
        assert.isTrue spyWrite.calledWith(message), 'Pipe::write did not called'
      .to.not.throw Error
    it 'should handle `LeanRC::JunctionMediator.REMOVE_PIPE` notification', ->
      expect ->
        MULTITON_KEY = 'TEST_JUNCTION_3'
        finalNode = write: ->
        outputPipe = Pipe.new()
        junction = Junction.new()
        spyRemovePipe = sinon.spy junction, 'removePipe'
        mediator = JunctionMediator.new 'TEST_MEDIATOR', junction
        mediator.initializeNotifier MULTITON_KEY
        acceptNotification = Notification.new JunctionMediator.ACCEPT_OUTPUT_PIPE, outputPipe, 'OUTPUT_PIPE'
        mediator.handleNotification acceptNotification
        assert.isTrue junction.hasPipe('OUTPUT_PIPE'), 'Pipe not registered'
        removeNotification = Notification.new JunctionMediator.REMOVE_PIPE, null, 'OUTPUT_PIPE'
        mediator.handleNotification removeNotification
        assert.isTrue spyRemovePipe.calledWith('OUTPUT_PIPE'), 'Junction::removePipe did not called'
        assert.isFalse junction.hasPipe('OUTPUT_PIPE'), 'Pipe not removed'
      .to.not.throw Error
  describe '#handlePipeMessage', ->
    it 'should send notification in handle', ->
      expect ->
        MULTITON_KEY = 'TEST_JUNCTION_4'
        junction = Junction.new()
        mediator = JunctionMediator.new 'TEST_MEDIATOR', junction
        mediator.initializeNotifier MULTITON_KEY
        message = PipeMessage.new PipeMessage.NORMAL
        spySendNotification = sinon.spy mediator, 'sendNotification'
        mediator.handlePipeMessage message
        assert.isTrue spySendNotification.calledWith(PipeMessage.NORMAL, message), 'JunctionMediator::handlePipeMessage did not called'
      .to.not.throw Error
