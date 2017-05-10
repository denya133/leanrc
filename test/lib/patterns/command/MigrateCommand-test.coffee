{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'MigrateCommand', ->
  describe '.new', ->
    it 'should create new command', ->
      co ->
        command = LeanRC::MigrateCommand.new()
        assert.instanceOf command, LeanRC::MigrateCommand
        yield return
  ###
  describe '#execute', ->
    it 'should create new command', ->
      co ->
        KEY = 'TEST_MIGRATE_COMMAND_002'
        facade = LeanRC::Facade.getInstance KEY
        trigger = sinon.spy ->
        trigger.reset()
        class Test extends LeanRC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestConfiguration extends LeanRC::Configuration
          @inheritProtected()
          @module Test
        TestConfiguration.initialize()
        configuration = TestConfiguration.new LeanRC::CONFIGURATION, Test::ROOT
        class TestCommand extends LeanRC::MigrateCommand
          @inheritProtected()
          @module Test
          @public execute: Function,
            default: -> trigger()
        TestCommand.initialize()
        facade.registerCommand 'TEST_MIGRATE', TestCommand
        facade.sendNotification 'TEST_MIGRATE'
        yield return
  ###
