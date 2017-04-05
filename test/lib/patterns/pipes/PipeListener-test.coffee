{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
PipeListener = LeanRC::PipeListener

describe 'PipeListener', ->
  describe '.new, #write', ->
    it 'should create new PipeListener instance', ->
      expect ->
        voOutput =
          write: ->
        vmListener = (aoMessage) ->
          @write aoMessage
        voMessage = message: 'TEST'
        spyWrite = sinon.spy voOutput, 'write'
        pipeListener = PipeListener.new voOutput, vmListener
        pipeListener.write voMessage
        assert.isTrue spyWrite.calledWith(voMessage), 'Message not passed into writer'
      .to.not.throw Error
