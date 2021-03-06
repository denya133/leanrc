{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Pipe = LeanRC::Pipes::Pipe
PipeMessage = LeanRC::Pipes::PipeMessage

describe 'Pipe', ->
  describe '.new', ->
    it 'should create new Pipe instance', ->
      expect ->
        voOutput = Pipe.new()
        pipe = Pipe.new voOutput
        assert.equal pipe[Symbol.for '~output'], voOutput, 'Output object is lost'
      .to.not.throw Error
  describe '#connect', ->
    it 'should create pipe and connect it to output', ->
      expect ->
        voOutput = Pipe.new()
        pipe = Pipe.new()
        pipe.connect voOutput
        assert.equal pipe[Symbol.for '~output'], voOutput, 'Output object is lost'
      .to.not.throw Error
  describe '#disconnect', ->
    it 'should create pipe and disconnect it', ->
      expect ->
        voOutput = Pipe.new()
        pipe = Pipe.new voOutput
        assert.equal pipe[Symbol.for '~output'], voOutput, 'Output object is lost'
        pipe.disconnect()
        assert.isNull pipe[Symbol.for '~output'], 'Output object is not cleared'
      .to.not.throw Error
  describe '#write', ->
    it 'should create and write to output', ->
      expect ->
        voOutput = Pipe.new()
        voMessage = PipeMessage.new PipeMessage.NORMAL
        spyWrite = sinon.spy voOutput, 'write'
        pipe = Pipe.new voOutput
        assert.equal pipe[Symbol.for '~output'], voOutput, 'Output object is lost'
        pipe.write voMessage
        assert.isTrue spyWrite.calledWith(voMessage), 'Message is not written'
      .to.not.throw Error
