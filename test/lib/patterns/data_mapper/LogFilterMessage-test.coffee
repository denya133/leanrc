{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'LogMessage', ->
  describe '.new', ->
    it 'should create new LogMessage instance', ->
      co ->
        vsAction = 'TEST_ACTION'
        vnLogLevel = 0
        message = LeanRC::LogFilterMessage.new vsAction, vnLogLevel
        assert.instanceOf message, LeanRC::LogFilterMessage
        assert.equal message[Symbol.for '~type'], vsAction
        assert.equal message[Symbol.for '~params'].logLevel, vnLogLevel
        assert.equal LeanRC::LogFilterMessage.BASE, 'namespaces/pipes/messages/filter-control/LoggerModule/'
        assert.equal LeanRC::LogFilterMessage.LOG_FILTER_NAME, 'namespaces/pipes/messages/filter-control/LoggerModule/logFilter/'
        assert.equal LeanRC::LogFilterMessage.SET_LOG_LEVEL, 'namespaces/pipes/messages/filter-control/LoggerModule/setLogLevel/'
        yield return
  describe '#logLevel', ->
    it 'should test logging level', ->
      co ->
        vsAction = 'TEST_ACTION'
        vnLogLevel = 0
        message = LeanRC::LogFilterMessage.new vsAction, vnLogLevel
        assert.equal message.logLevel, vnLogLevel
        vnLogLevel = 1
        message = LeanRC::LogFilterMessage.new vsAction, vnLogLevel
        assert.equal message.logLevel, vnLogLevel
        vnLogLevel = 42
        message = LeanRC::LogFilterMessage.new vsAction, vnLogLevel
        assert.equal message.logLevel, vnLogLevel
        vnLogLevel = 999
        message = LeanRC::LogFilterMessage.new vsAction, vnLogLevel
        assert.equal message.logLevel, vnLogLevel
        yield return
