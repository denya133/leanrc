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
