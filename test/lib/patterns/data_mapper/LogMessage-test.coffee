{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'LogMessage', ->
  describe '.new', ->
    it 'should create new LogMessage instance', ->
      co ->
        vnLevel = LeanRC::LogMessage.NORMAL
        vsSender = 'TEST_SENDER'
        vsMessage = 'TEST_MESSAGE'
        message = LeanRC::LogMessage.new vnLevel, vsSender, vsMessage
        assert.instanceOf message, LeanRC::LogMessage
        assert.deepEqual message[Symbol.for '~header'].logLevel, vnLevel
        assert.deepEqual message[Symbol.for '~header'].sender, vsSender
        assert.equal message[Symbol.for '~body'], vsMessage
        assert.equal message[Symbol.for '~type'], LeanRC::Pipes::PipeMessage.NORMAL
        assert.equal message[Symbol.for '~priority'], LeanRC::Pipes::PipeMessage.PRIORITY_MED
        yield return
