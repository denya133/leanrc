{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require '../lib'
MacroCommand = LeanRC::MacroCommand
SimpleCommand = LeanRC::SimpleCommand

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
        command = MacroCommand.new()
        command1Execute = sinon.spy ->
        class TestCommand1 extends SimpleCommand
          @inheritProtected()
          @public execute: Function,
            default: command1Execute
        command2Execute = sinon.spy ->
        class TestCommand2 extends SimpleCommand
          @inheritProtected()
          @public execute: Function,
            default: command2Execute
        command.addSubCommand TestCommand1
        command.addSubCommand TestCommand2
        command.execute()
        assert command1Execute.called
        assert command2Execute.called
        assert command2Execute.calledAfter command1Execute
      .to.not.throw Error
