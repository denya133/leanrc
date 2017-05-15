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
        assert.equal message[Symbol.for '~header'].logLevel, vnLevel
        assert.deepEqual message[Symbol.for '~header'].sender, vsSender
        assert.equal message[Symbol.for '~body'], vsMessage
        assert.equal message[Symbol.for '~type'], LeanRC::Pipes::PipeMessage.NORMAL
        assert.equal message[Symbol.for '~priority'], LeanRC::Pipes::PipeMessage.PRIORITY_MED
        assert.deepEqual LeanRC::LogMessage.LEVELS, [
          'NONE', 'FATAL', 'ERROR', 'WARN', 'INFO', 'DEBUG'
        ]
        assert.equal LeanRC::LogMessage.SEND_TO_LOG, 'namespaces/pipes/messages/LoggerModule/sendToLog'
        assert.equal LeanRC::LogMessage.STDLOG, 'standardLog'
        yield return
  describe '#logLevel', ->
    it 'should test logging level', ->
      co ->
        vnLevel = -2
        vsSender = 'TEST_SENDER'
        vsMessage = 'TEST_MESSAGE'
        message = LeanRC::LogMessage.new vnLevel, vsSender, vsMessage
        assert.equal message[Symbol.for '~header'].logLevel, vnLevel
        message.logLevel = LeanRC::LogMessage.CHANGE
        assert.equal message.logLevel, LeanRC::LogMessage.CHANGE
        assert.equal message[Symbol.for '~header'].logLevel, LeanRC::LogMessage.CHANGE
        message.logLevel = LeanRC::LogMessage.NONE
        assert.equal message.logLevel, LeanRC::LogMessage.NONE
        assert.equal message[Symbol.for '~header'].logLevel, LeanRC::LogMessage.NONE
        message.logLevel = LeanRC::LogMessage.FATAL
        assert.equal message.logLevel, LeanRC::LogMessage.FATAL
        assert.equal message[Symbol.for '~header'].logLevel, LeanRC::LogMessage.FATAL
        message.logLevel = LeanRC::LogMessage.ERROR
        assert.equal message.logLevel, LeanRC::LogMessage.ERROR
        assert.equal message[Symbol.for '~header'].logLevel, LeanRC::LogMessage.ERROR
        message.logLevel = LeanRC::LogMessage.WARN
        assert.equal message.logLevel, LeanRC::LogMessage.WARN
        assert.equal message[Symbol.for '~header'].logLevel, LeanRC::LogMessage.WARN
        message.logLevel = LeanRC::LogMessage.INFO
        assert.equal message.logLevel, LeanRC::LogMessage.INFO
        assert.equal message[Symbol.for '~header'].logLevel, LeanRC::LogMessage.INFO
        message.logLevel = LeanRC::LogMessage.DEBUG
        assert.equal message.logLevel, LeanRC::LogMessage.DEBUG
        assert.equal message[Symbol.for '~header'].logLevel, LeanRC::LogMessage.DEBUG
        yield return
  describe '#sender', ->
    it 'should test sender', ->
      co ->
        vnLevel = LeanRC::LogMessage.NONE
        vsSender = 'TEST_SENDER'
        vsMessage = 'TEST_MESSAGE'
        message = LeanRC::LogMessage.new vnLevel, vsSender, vsMessage
        assert.equal message[Symbol.for '~header'].sender, vsSender
        assert.equal message.sender, vsSender
        vsSender = 'TEST_ANOTHER_SENDER'
        message.sender = vsSender
        assert.equal message[Symbol.for '~header'].sender, vsSender
        assert.equal message.sender, vsSender
        yield return
  describe '#time', ->
    it 'should test time', ->
      co ->
        vnLevel = LeanRC::LogMessage.NONE
        vsSender = 'TEST_SENDER'
        vsMessage = 'TEST_MESSAGE'
        message = LeanRC::LogMessage.new vnLevel, vsSender, vsMessage
        vsTime = new Date().toISOString()
        message.time = vsTime
        assert.equal message[Symbol.for '~header'].time, vsTime
        assert.equal message.time, vsTime
        yield return
