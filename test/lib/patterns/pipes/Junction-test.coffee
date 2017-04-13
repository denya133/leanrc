{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Junction = LeanRC::Junction
Pipe = LeanRC::Pipe

describe 'Junction', ->
  describe '.new', ->
    it 'should create new Junction instance', ->
      expect ->
        junction = Junction.new()
      .to.not.throw Error
  describe '#registerPipe', ->
    it 'should register pipe into junction', ->
      expect ->
        junction = Junction.new()
        inputPipe = Pipe.new()
        outputPipe = Pipe.new()
        inputRegistered = junction.registerPipe 'TEST_INPUT', Junction.INPUT, inputPipe
        assert.isTrue inputRegistered, 'TEST_INPUT not registered'
        assert.equal junction[Symbol.for '~pipesMap']['TEST_INPUT'], inputPipe, 'TEST_INPUT pipe not registered'
        assert.equal junction[Symbol.for '~pipeTypesMap']['TEST_INPUT'], Junction.INPUT, 'TEST_INPUT pipe type not registered'
        assert.include junction[Symbol.for '~inputPipes'], 'TEST_INPUT', 'Input pipes do not contain TEST_INPUT'
        outputRegistered = junction.registerPipe 'TEST_OUTPUT', Junction.OUTPUT, outputPipe
        assert.isTrue outputRegistered, 'TEST_OUTPUT not registered'
        assert.equal junction[Symbol.for '~pipesMap']['TEST_OUTPUT'], outputPipe, 'TEST_OUTPUT pipe not registered'
        assert.equal junction[Symbol.for '~pipeTypesMap']['TEST_OUTPUT'], Junction.OUTPUT, 'TEST_OUTPUT pipe type not registered'
        assert.include junction[Symbol.for '~outputPipes'], 'TEST_OUTPUT', 'Input pipes do not contain TEST_OUTPUT'
      .to.not.throw Error
  describe '#removePipe', ->
    it 'should register pipe into junction and remove it after that', ->
      expect ->
        junction = Junction.new()
        inputPipe = Pipe.new()
        outputPipe = Pipe.new()
        inputRegistered = junction.registerPipe 'TEST_INPUT', Junction.INPUT, inputPipe
        assert.isTrue inputRegistered, 'TEST_INPUT not registered'
        assert.equal junction[Symbol.for '~pipesMap']['TEST_INPUT'], inputPipe, 'TEST_INPUT pipe not registered'
        assert.equal junction[Symbol.for '~pipeTypesMap']['TEST_INPUT'], Junction.INPUT, 'TEST_INPUT pipe type not registered'
        assert.include junction[Symbol.for '~inputPipes'], 'TEST_INPUT', 'Input pipes do not contain TEST_INPUT'
        outputRegistered = junction.registerPipe 'TEST_OUTPUT', Junction.OUTPUT, outputPipe
        assert.isTrue outputRegistered, 'TEST_OUTPUT not registered'
        assert.equal junction[Symbol.for '~pipesMap']['TEST_OUTPUT'], outputPipe, 'TEST_OUTPUT pipe not registered'
        assert.equal junction[Symbol.for '~pipeTypesMap']['TEST_OUTPUT'], Junction.OUTPUT, 'TEST_OUTPUT pipe type not registered'
        assert.include junction[Symbol.for '~outputPipes'], 'TEST_OUTPUT', 'Input pipes do not contain TEST_OUTPUT'
        junction.removePipe 'TEST_INPUT', Junction.INPUT, inputPipe
        assert.isUndefined junction[Symbol.for '~pipesMap']['TEST_INPUT'], 'TEST_INPUT pipe not registered'
        assert.isUndefined junction[Symbol.for '~pipeTypesMap']['TEST_INPUT'], 'TEST_INPUT pipe type not registered'
        assert.notInclude junction[Symbol.for '~inputPipes'], 'TEST_INPUT', 'Input pipes do not contain TEST_INPUT'
        junction.removePipe 'TEST_OUTPUT', Junction.OUTPUT, outputPipe
        assert.isUndefined junction[Symbol.for '~pipesMap']['TEST_OUTPUT'], 'TEST_OUTPUT pipe not registered'
        assert.isUndefined junction[Symbol.for '~pipeTypesMap']['TEST_OUTPUT'], 'TEST_OUTPUT pipe type not registered'
        assert.notInclude junction[Symbol.for '~outputPipes'], 'TEST_OUTPUT', 'Input pipes do not contain TEST_OUTPUT'
      .to.not.throw Error
  describe '#retrievePipe', ->
    it 'should register pipe and get it', ->
      expect ->
        junction = Junction.new()
        inputPipe = Pipe.new()
        junction.registerPipe 'TEST_INPUT', Junction.INPUT, inputPipe
        assert.equal junction.retrievePipe('TEST_INPUT'), inputPipe, 'TEST_INPUT pipe not registered'
      .to.not.throw Error
  describe '#hasPipe', ->
    it 'should register pipe and test its presence', ->
      expect ->
        junction = Junction.new()
        inputPipe = Pipe.new()
        junction.registerPipe 'TEST_INPUT', Junction.INPUT, inputPipe
        assert.isTrue junction.hasPipe('TEST_INPUT'), 'TEST_INPUT pipe not registered'
      .to.not.throw Error
  describe '#hasInputPipe', ->
    it 'should register input pipe and test its presence', ->
      expect ->
        junction = Junction.new()
        inputPipe = Pipe.new()
        junction.registerPipe 'TEST_INPUT', Junction.INPUT, inputPipe
        assert.isTrue junction.hasInputPipe('TEST_INPUT'), 'TEST_INPUT pipe not registered'
      .to.not.throw Error
  describe '#hasOutputPipe', ->
    it 'should register output pipe and test its presence', ->
      expect ->
        junction = Junction.new()
        outputPipe = Pipe.new()
        junction.registerPipe 'TEST_OUTPUT', Junction.OUTPUT, outputPipe
        assert.isTrue junction.hasOutputPipe('TEST_OUTPUT'), 'TEST_OUTPUT pipe not registered'
      .to.not.throw Error
  describe '#addPipeListener', ->
    it 'should register input pipe and connect it to listener', ->
      expect ->
        context = test: ->
        spyTest = sinon.spy context, 'test'
        junction = Junction.new()
        inputPipe = Pipe.new()
        junction.registerPipe 'TEST_INPUT', Junction.INPUT, inputPipe
        junction.addPipeListener 'TEST_INPUT', context, (aoMessage) -> @test aoMessage
        assert.isTrue junction.hasInputPipe('TEST_INPUT'), 'TEST_INPUT pipe not registered'
        message = LeanRC::PipeMessage.new LeanRC::PipeMessage.NORMAL
        inputPipe.write message
        assert.isTrue spyTest.calledWith(message), 'Listener did not called on context'
      .to.not.throw Error
  describe '#sendMessage', ->
    it 'should register output pipe and send message into this one', ->
      expect ->
        voOutput = write: ->
        spyWrite = sinon.spy voOutput, 'write'
        junction = Junction.new()
        outputPipe = Pipe.new voOutput
        message = LeanRC::PipeMessage.new LeanRC::PipeMessage.NORMAL
        junction.registerPipe 'TEST_OUTPUT', Junction.OUTPUT, outputPipe
        junction.sendMessage 'TEST_OUTPUT', message
        assert.isTrue spyWrite.calledWith(message), 'Message received with context'
      .to.not.throw Error
