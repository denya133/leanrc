{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
SimpleCommand = LeanRC::SimpleCommand

describe 'SimpleCommand', ->
  describe '.new', ->
    it 'should create new command', ->
      expect ->
        command = SimpleCommand.new()
      .to.not.throw Error
  describe '#execute', ->
    it 'should create new command', ->
      expect ->
        trigger = sinon.spy()
        trigger.reset()
        class TestCommand extends SimpleCommand
          @inheritProtected()
          @public execute: Function,
            default: ->
              trigger()
        command = TestCommand.new()
        command.execute()
        assert trigger.called
      .to.not.throw Error
