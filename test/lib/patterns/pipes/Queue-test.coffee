{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
Queue = LeanRC::Pipes::Queue
PipeMessage = LeanRC::Pipes::PipeMessage
QueueControlMessage = LeanRC::Pipes::QueueControlMessage

describe 'Queue', ->
  describe '.new', ->
    it 'should create new Queue instance', ->
      expect ->
        voOutput = {}
        queue = Queue.new voOutput
        assert.equal queue[Symbol.for '~output'], voOutput, 'Output object is lost'
      .to.not.throw Error
  describe '#write', ->
    it 'should get message with type `LeanRC::PipeMessage.NORMAL` and store it', ->
      expect ->
        voOutput = write: -> yes
        queue = Queue.new voOutput
        message = PipeMessage.new PipeMessage.NORMAL
        queue.write message
        assert.equal queue[Symbol.for '~messages'][0], message, 'Message was not saved'
      .to.not.throw Error
    it 'should get message with type `LeanRC::QueueControlMessage.FLUSH` and flush queue', ->
      expect ->
        length = 3
        voOutput = write: -> yes
        spyOutputWrite = sinon.spy voOutput, 'write'
        queue = Queue.new voOutput
        message = PipeMessage.new PipeMessage.NORMAL
        queue.write message  for i in [1 .. length]
        assert.equal queue[Symbol.for '~messages'].length, length, 'Messages were not saved'
        message = QueueControlMessage.new LeanRC::Pipes::QueueControlMessage.FLUSH
        res = queue.write message
        assert.equal queue[Symbol.for '~messages'].length, 0, 'Messages not flushed'
        assert.equal spyOutputWrite.callCount, length, 'Message not queued'
      .to.not.throw Error
    it 'should get message with type `LeanRC::QueueControlMessage.SORT` and fill queue', ->
      expect ->
        length = 3
        voOutput = write: -> yes
        spyOutputWrite = sinon.spy voOutput, 'write'
        queue = Queue.new voOutput
        message = QueueControlMessage.new LeanRC::Pipes::QueueControlMessage.SORT
        res = queue.write message
        for i in [1 .. length]
          message = PipeMessage.new PipeMessage.NORMAL, null, "MESSAGE_#{i}",  length - i
          queue.write message
        assert.equal queue[Symbol.for '~messages'][0].getBody(), 'MESSAGE_3', 'Message 0 is incorrect'
        assert.equal queue[Symbol.for '~messages'][1].getBody(), 'MESSAGE_2', 'Message 1 is incorrect'
        assert.equal queue[Symbol.for '~messages'][2].getBody(), 'MESSAGE_1', 'Message 2 is incorrect'
      .to.not.throw Error
    it 'should get message with type `LeanRC::QueueControlMessage.FIFO` and fill queue', ->
      expect ->
        length = 3
        voOutput = write: -> yes
        spyOutputWrite = sinon.spy voOutput, 'write'
        queue = Queue.new voOutput
        message = QueueControlMessage.new LeanRC::Pipes::QueueControlMessage.FIFO
        res = queue.write message
        for i in [1 .. length]
          message = PipeMessage.new PipeMessage.NORMAL, null, "MESSAGE_#{i}",  length - i
          queue.write message
        assert.equal queue[Symbol.for '~messages'][0].getBody(), 'MESSAGE_1', 'Message 0 is incorrect'
        assert.equal queue[Symbol.for '~messages'][1].getBody(), 'MESSAGE_2', 'Message 1 is incorrect'
        assert.equal queue[Symbol.for '~messages'][2].getBody(), 'MESSAGE_3', 'Message 2 is incorrect'
      .to.not.throw Error
