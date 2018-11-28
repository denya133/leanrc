{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'LogMessageCommand', ->
  describe '.new', ->
    it 'should create new command', ->
      co ->
        command = LeanRC::LogMessageCommand.new()
        assert.instanceOf command, LeanRC::LogMessageCommand
        yield return
  describe '#execute', ->
    it 'should create new command', ->
      co ->
        KEY = 'TEST_LOG_MESSAGE_COMMAND_001'
        facade = LeanRC::Facade.getInstance KEY
        spyAddLogEntry = sinon.spy ->
        class Test extends LeanRC
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class TestProxy extends LeanRC::Proxy
          @inheritProtected()
          @module Test
          @public addLogEntry: Function,
            default: spyAddLogEntry
        TestProxy.initialize()
        facade.registerProxy TestProxy.new LeanRC::Application::LOGGER_PROXY
        command = LeanRC::LogMessageCommand.new()
        command.initializeNotifier KEY
        body = data: 'data'
        command.execute LeanRC::Notification.new 'TEST', body, 'TYPE'
        assert.isTrue spyAddLogEntry.calledWith body
        facade.remove()
        yield return
