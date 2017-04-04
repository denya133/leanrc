{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
JunctionMediator = LeanRC::JunctionMediator
Junction = LeanRC::Junction
Pipe = LeanRC::Pipe
Notification = LeanRC::Notification
PipeMessage = LeanRC::PipeMessage

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
