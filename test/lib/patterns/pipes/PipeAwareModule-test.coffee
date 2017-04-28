{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Facade = LeanRC::Facade
PipeAwareModule = LeanRC::Pipes::PipeAwareModule
Pipe = LeanRC::Pipes::Pipe
JunctionMediator = LeanRC::Pipes::JunctionMediator

describe 'PipeAwareModule', ->
  describe '.new', ->
    it 'should create new PipeAwareModule instance', ->
      expect ->
        facade = Facade.getInstance 'TEST_PIPE_AWARE_1'
        pipeAwareModule = PipeAwareModule.new facade
        assert.equal pipeAwareModule.facade, facade, 'Facade is incorrect'
      .to.not.throw Error
  describe '#acceptInputPipe', ->
    it 'should send pipe as input pipe into notification', ->
      expect ->
        facade = Facade.getInstance 'TEST_PIPE_AWARE_2'
        pipeAwareModule = PipeAwareModule.new facade
        pipe = Pipe.new()
        spyFunction = sinon.spy facade, 'sendNotification'
        pipeAwareModule.acceptInputPipe 'PIPE_1', pipe
        assert.isTrue spyFunction.calledWith(JunctionMediator.ACCEPT_INPUT_PIPE, pipe, 'PIPE_1'), 'Notification not sent'
      .to.not.throw Error
  describe '#acceptOutputPipe', ->
    it 'should send pipe as output pipe into notification', ->
      expect ->
        facade = Facade.getInstance 'TEST_PIPE_AWARE_3'
        pipeAwareModule = PipeAwareModule.new facade
        pipe = Pipe.new()
        spyFunction = sinon.spy facade, 'sendNotification'
        pipeAwareModule.acceptOutputPipe 'PIPE_2', pipe
        assert.isTrue spyFunction.calledWith(JunctionMediator.ACCEPT_OUTPUT_PIPE, pipe, 'PIPE_2'), 'Notification not sent'
      .to.not.throw Error
