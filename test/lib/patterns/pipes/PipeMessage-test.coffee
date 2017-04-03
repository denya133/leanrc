{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
PipeMessage = LeanRC::PipeMessage

describe 'PipeMessage', ->
  describe '.new', ->
    it 'should create new PipeMessage instance', ->
      expect ->
        vnPriority = PipeMessage.PRIORITY_MED
        vsType = PipeMessage.NORMAL
        voHeader = header: 'test'
        voBody = message: 'TEST'
        message = PipeMessage.new vsType, voHeader, voBody, vnPriority
        assert.equal message[Symbol.for 'type'], vsType, 'Type is incorrect'
        assert.equal message[Symbol.for 'priority'], vnPriority, 'Priority is incorrect'
        assert.equal message[Symbol.for 'header'], voHeader, 'Header is incorrect'
        assert.equal message[Symbol.for 'body'], voBody, 'Body is incorrect'
      .to.not.throw Error
