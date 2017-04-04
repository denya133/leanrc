{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
QueueControlMessage = LeanRC::QueueControlMessage

describe 'QueueControlMessage', ->
  describe '.new', ->
    it 'should create new QueueControlMessage instance', ->
      expect ->
        vsType = QueueControlMessage.FIFO
        message = QueueControlMessage.new vsType
        assert.equal message[Symbol.for 'type'], vsType, 'Type is incorrect'
      .to.not.throw Error
