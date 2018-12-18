{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Line = LeanRC::Pipes::Line
Pipe = LeanRC::Pipes::Pipe
PipeMessage = LeanRC::Pipes::PipeMessage
LineControlMessage = LeanRC::Pipes::LineControlMessage

describe 'Line', ->
  describe '.new', ->
    it 'should create new Line instance', ->
      expect ->
        voOutput = Pipe.new()
        queue = Line.new voOutput
        assert.equal queue[Symbol.for '~output'], voOutput, 'Output object is lost'
      .to.not.throw Error
  describe '#write', ->
    it 'should get message with type `LeanRC::PipeMessage.NORMAL` and store it', ->
      expect ->
        voOutput = Pipe.new()
        queue = Line.new voOutput
        message = PipeMessage.new PipeMessage.NORMAL
        queue.write message
        assert.equal queue[Symbol.for '~messages'][0], message, 'Message was not saved'
      .to.not.throw Error
    it 'should get message with type `LeanRC::LineControlMessage.FLUSH` and flush queue', ->
      expect ->
        length = 3
        voOutput = Pipe.new()
        spyOutputWrite = sinon.spy voOutput, 'write'
        queue = Line.new voOutput
        message = PipeMessage.new PipeMessage.NORMAL
        queue.write message  for i in [1 .. length]
        assert.equal queue[Symbol.for '~messages'].length, length, 'Messages were not saved'
        message = LineControlMessage.new LeanRC::Pipes::LineControlMessage.FLUSH
        res = queue.write message
        assert.equal queue[Symbol.for '~messages'].length, 0, 'Messages not flushed'
        assert.equal spyOutputWrite.callCount, length, 'Message not queued'
      .to.not.throw Error
    it 'should get message with type `LeanRC::LineControlMessage.SORT` and fill queue', ->
      expect ->
        length = 3
        voOutput = Pipe.new()
        spyOutputWrite = sinon.spy voOutput, 'write'
        queue = Line.new voOutput
        message = LineControlMessage.new LeanRC::Pipes::LineControlMessage.SORT
        res = queue.write message
        for i in [1 .. length]
          message = PipeMessage.new PipeMessage.NORMAL, null, {[i]: "MESSAGE_#{i}"},  length - i
          queue.write message
        assert.deepEqual queue[Symbol.for '~messages'][0].getBody(), {3: 'MESSAGE_3'}, 'Message 0 is incorrect'
        assert.deepEqual queue[Symbol.for '~messages'][1].getBody(), {2: 'MESSAGE_2'}, 'Message 1 is incorrect'
        assert.deepEqual queue[Symbol.for '~messages'][2].getBody(), {1: 'MESSAGE_1'}, 'Message 2 is incorrect'
      .to.not.throw Error
    it 'should get message with type `LeanRC::LineControlMessage.FIFO` and fill queue', ->
      expect ->
        length = 3
        voOutput = Pipe.new()
        spyOutputWrite = sinon.spy voOutput, 'write'
        queue = Line.new voOutput
        message = LineControlMessage.new LeanRC::Pipes::LineControlMessage.FIFO
        res = queue.write message
        for i in [1 .. length]
          message = PipeMessage.new PipeMessage.NORMAL, null, {[i]: "MESSAGE_#{i}"},  length - i
          queue.write message
        assert.deepEqual queue[Symbol.for '~messages'][0].getBody(), {1: 'MESSAGE_1'}, 'Message 0 is incorrect'
        assert.deepEqual queue[Symbol.for '~messages'][1].getBody(), {2: 'MESSAGE_2'}, 'Message 1 is incorrect'
        assert.deepEqual queue[Symbol.for '~messages'][2].getBody(), {3: 'MESSAGE_3'}, 'Message 2 is incorrect'
      .to.not.throw Error
