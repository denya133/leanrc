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
        assert.equal junction[Symbol.for 'pipesMap']['TEST_INPUT'], inputPipe, 'TEST_INPUT pipe not registered'
        assert.equal junction[Symbol.for 'pipeTypesMap']['TEST_INPUT'], Junction.INPUT, 'TEST_INPUT pipe type not registered'
        assert.include junction[Symbol.for 'inputPipes'], 'TEST_INPUT', 'Input pipes do not contain TEST_INPUT'
        outputRegistered = junction.registerPipe 'TEST_OUTPUT', Junction.OUTPUT, outputPipe
        assert.isTrue outputRegistered, 'TEST_OUTPUT not registered'
        assert.equal junction[Symbol.for 'pipesMap']['TEST_OUTPUT'], outputPipe, 'TEST_OUTPUT pipe not registered'
        assert.equal junction[Symbol.for 'pipeTypesMap']['TEST_OUTPUT'], Junction.OUTPUT, 'TEST_OUTPUT pipe type not registered'
        assert.include junction[Symbol.for 'outputPipes'], 'TEST_OUTPUT', 'Input pipes do not contain TEST_OUTPUT'
      .to.not.throw Error
  describe '#removePipe', ->
    it 'should register pipe into junction and remove it after that', ->
      expect ->
        junction = Junction.new()
        inputPipe = Pipe.new()
        outputPipe = Pipe.new()
        inputRegistered = junction.registerPipe 'TEST_INPUT', Junction.INPUT, inputPipe
        assert.isTrue inputRegistered, 'TEST_INPUT not registered'
        assert.equal junction[Symbol.for 'pipesMap']['TEST_INPUT'], inputPipe, 'TEST_INPUT pipe not registered'
        assert.equal junction[Symbol.for 'pipeTypesMap']['TEST_INPUT'], Junction.INPUT, 'TEST_INPUT pipe type not registered'
        assert.include junction[Symbol.for 'inputPipes'], 'TEST_INPUT', 'Input pipes do not contain TEST_INPUT'
        outputRegistered = junction.registerPipe 'TEST_OUTPUT', Junction.OUTPUT, outputPipe
        assert.isTrue outputRegistered, 'TEST_OUTPUT not registered'
        assert.equal junction[Symbol.for 'pipesMap']['TEST_OUTPUT'], outputPipe, 'TEST_OUTPUT pipe not registered'
        assert.equal junction[Symbol.for 'pipeTypesMap']['TEST_OUTPUT'], Junction.OUTPUT, 'TEST_OUTPUT pipe type not registered'
        assert.include junction[Symbol.for 'outputPipes'], 'TEST_OUTPUT', 'Input pipes do not contain TEST_OUTPUT'
        junction.removePipe 'TEST_INPUT', Junction.INPUT, inputPipe
        assert.isUndefined junction[Symbol.for 'pipesMap']['TEST_INPUT'], 'TEST_INPUT pipe not registered'
        assert.isUndefined junction[Symbol.for 'pipeTypesMap']['TEST_INPUT'], 'TEST_INPUT pipe type not registered'
        assert.notInclude junction[Symbol.for 'inputPipes'], 'TEST_INPUT', 'Input pipes do not contain TEST_INPUT'
        junction.removePipe 'TEST_OUTPUT', Junction.OUTPUT, outputPipe
        assert.isUndefined junction[Symbol.for 'pipesMap']['TEST_OUTPUT'], 'TEST_OUTPUT pipe not registered'
        assert.isUndefined junction[Symbol.for 'pipeTypesMap']['TEST_OUTPUT'], 'TEST_OUTPUT pipe type not registered'
        assert.notInclude junction[Symbol.for 'outputPipes'], 'TEST_OUTPUT', 'Input pipes do not contain TEST_OUTPUT'
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
