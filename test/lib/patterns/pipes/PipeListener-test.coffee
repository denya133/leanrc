{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
PipeListener = LeanRC::Pipes::PipeListener
Pipe = LeanRC::Pipes::Pipe
PipeMessage = LeanRC::Pipes::PipeMessage

describe 'PipeListener', ->
  describe '.new, #write', ->
    it 'should create new PipeListener instance', ->
      expect ->
        voOutput = Pipe.new()
        vmListener = (aoMessage) ->
          @write aoMessage
        voMessage = PipeMessage.new PipeMessage.NORMAL
        spyWrite = sinon.spy voOutput, 'write'
        pipeListener = PipeListener.new voOutput, vmListener
        pipeListener.write voMessage
        assert.isTrue spyWrite.calledWith(voMessage), 'Message not passed into writer'
      .to.not.throw Error
