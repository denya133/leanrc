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
  describe '#initializeNotifier', ->
    it 'should initialize command', ->
      co ->
        KEY = 'TEST_MIGRATE_COMMAND_001'
        facade = LeanRC::Facade.getInstance KEY
        trigger = sinon.spy ->
        trigger.reset()
        class Test extends LeanRC::Module
          @inheritProtected()
          @root "#{__dirname}/config/root"
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attr 'test': String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'TestRecord'
        TestRecord.initialize()
        class TestMemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        TestMemoryCollection.initialize()
        class TestCommand extends LeanRC::MigrateCommand
          @inheritProtected()
          @module Test
          @public execute: Function,
            default: -> trigger()
        TestCommand.initialize()
        facade.registerProxy TestMemoryCollection.new LeanRC::MIGRATIONS,
          delegate: TestRecord
          serializer: LeanRC::Serializer
        command = LeanRC::MigrateCommand.new()
        command.initializeNotifier KEY
        assert.equal command.migrationsCollection, facade.retrieveProxy LeanRC::MIGRATIONS
        assert.isNotNull command.migrationsCollection
        assert.isDefined command.migrationsCollection
        yield return
