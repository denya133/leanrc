{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{
  NilT
  FuncG
  NotificationInterface
  Notification
  MacroCommand
  SimpleCommand
} = LeanRC::

describe 'MacroCommand', ->
  describe '.new', ->
    it 'should create new macro command', ->
      expect ->
        command = MacroCommand.new()
      .to.not.throw Error
  describe '#initializeMacroCommand', ->
    it 'should initialize macro command', ->
      expect ->
        initializeMacroCommand = sinon.spy()
        class TestMacroCommand extends MacroCommand
          @inheritProtected()
          @public initializeMacroCommand: Function,
            default: initializeMacroCommand
        command = TestMacroCommand.new()
        assert initializeMacroCommand.called
      .to.not.throw Error
  describe '#addSubCommand', ->
    it 'should add sub-command and execute macro', ->
      expect ->
        KEY = 'TEST_MACRO_COMMAND_001'
        facade = LeanRC::Facade.getInstance KEY
        command = MacroCommand.new()
        command.initializeNotifier KEY
        command1Execute = sinon.spy ->
        class TestCommand1 extends SimpleCommand
          @inheritProtected()
          @public execute: FuncG(NotificationInterface, NilT),
            default: command1Execute
        command2Execute = sinon.spy ->
        class TestCommand2 extends SimpleCommand
          @inheritProtected()
          @public execute: FuncG(NotificationInterface, NilT),
            default: command2Execute
        command.addSubCommand TestCommand1
        command.addSubCommand TestCommand2
        notification = Notification.new 'TEST_NOTIFICATION', {body: 'body'}, 'TEST'
        command.execute notification
        assert command1Execute.called
        assert command2Execute.called
        assert command2Execute.calledAfter command1Execute
      .to.not.throw Error
