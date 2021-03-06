EventEmitter = require 'events'
{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{
  NilT
  FuncG, SubsetG, MaybeG, UnionG, StructG
  RecordInterface, CollectionInterface
  Utils: { co }
} = LeanRC::

describe 'RollbackCommand', ->
  describe '.new', ->
    it 'should create new command', ->
      co ->
        command = LeanRC::RollbackCommand.new()
        assert.instanceOf command, LeanRC::RollbackCommand
        yield return
  describe '#initializeNotifier', ->
    it 'should initialize command', ->
      co ->
        KEY = 'TEST_ROLLBACK_COMMAND_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include LeanRC::SchemaModuleMixin
          @root "#{__dirname}/config/root"
          @defineMigrations()
        Test.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attr 'test': String
          @public init: FuncG([Object, CollectionInterface], NilT),
            default: ->
              @super arguments...
              @type = 'TestRecord'
              return
        TestRecord.initialize()
        class TestMemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        TestMemoryCollection.initialize()
        facade.registerProxy TestMemoryCollection.new LeanRC::MIGRATIONS,
          delegate: TestRecord
          serializer: LeanRC::Serializer
        command = LeanRC::RollbackCommand.new()
        command.initializeNotifier KEY
        assert.equal command.migrationsCollection, facade.retrieveProxy LeanRC::MIGRATIONS
        assert.isNotNull command.migrationsCollection
        assert.isDefined command.migrationsCollection
        facade.remove()
        yield return
  describe '#migrationsDir', ->
    it 'should get migrations directory path', ->
      co ->
        KEY = 'TEST_ROLLBACK_COMMAND_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include LeanRC::SchemaModuleMixin
          @root "#{__dirname}/config/root"
          @defineMigrations()
        Test.initialize()
        class TestConfiguration extends LeanRC::Configuration
          @inheritProtected()
          @module Test
        TestConfiguration.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attr 'test': String
          @public init: FuncG([Object, CollectionInterface], NilT),
            default: ->
              @super arguments...
              @type = 'TestRecord'
              return
        TestRecord.initialize()
        class TestMemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        TestMemoryCollection.initialize()
        facade.registerProxy TestMemoryCollection.new LeanRC::MIGRATIONS,
          delegate: TestRecord
          serializer: LeanRC::Serializer
        facade.registerProxy TestConfiguration.new LeanRC::CONFIGURATION, Test::ROOT
        command = LeanRC::RollbackCommand.new()
        command.initializeNotifier KEY
        { migrationsDir } = command
        assert.equal migrationsDir, "#{Test::ROOT}/migrations"
        facade.remove()
        yield return
  describe '#migrationNames', ->
    it 'should get migration names', ->
      co ->
        KEY = 'TEST_ROLLBACK_COMMAND_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC
          @inheritProtected()
          @include LeanRC::SchemaModuleMixin
          @root "#{__dirname}/config/root"
          @defineMigrations()
        Test.initialize()
        class TestConfiguration extends LeanRC::Configuration
          @inheritProtected()
          @module Test
        TestConfiguration.initialize()
        class TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attr 'test': String
          @public init: FuncG([Object, CollectionInterface], NilT),
            default: ->
              @super arguments...
              @type = 'TestRecord'
              return
        TestRecord.initialize()
        class TestMemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        TestMemoryCollection.initialize()
        class TestCommand extends LeanRC::RollbackCommand
          @inheritProtected()
          @module Test
        TestCommand.initialize()
        facade.registerProxy TestMemoryCollection.new LeanRC::MIGRATIONS,
          delegate: TestRecord
          serializer: LeanRC::Serializer
        facade.registerProxy TestConfiguration.new LeanRC::CONFIGURATION, Test::ROOT
        class ApplicationMediator extends LeanRC::Mediator
          @inheritProtected()
          @module Test
        ApplicationMediator.initialize()
        class TestApplication extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
        TestApplication.initialize()
        facade.registerMediator ApplicationMediator.new LeanRC::APPLICATION_MEDIATOR, TestApplication.new()
        command = TestCommand.new()
        command.initializeNotifier KEY
        migrationNames = command.migrationNames
        assert.deepEqual migrationNames, [ '01_migration', '02_migration', '03_migration' ]
        facade.remove()
        yield return
  describe '#rollback', ->
    it 'should run migrations', ->
      co ->
        KEY = 'TEST_ROLLBACK_COMMAND_004'
        facade = LeanRC::Facade.getInstance KEY
        defineMigration = (Module) ->
          class TestMigration extends LeanRC::Migration
            @inheritProtected()
            @module Module
            @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
              default: -> Test::TestMigration
            @public init: FuncG([Object, CollectionInterface], NilT),
              default: (args...) ->
                @super args...
                @type = 'TestMigration'
                return
          TestMigration.initialize()
        class Test extends LeanRC
          @inheritProtected()
          @include LeanRC::SchemaModuleMixin
          @root "#{__dirname}/config/root2"
          defineMigration @Module
          @defineMigrations()
        Test.initialize()
        class TestConfiguration extends LeanRC::Configuration
          @inheritProtected()
          @module Test
        TestConfiguration.initialize()
        class TestMemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        TestMemoryCollection.initialize()
        class TestCommand extends LeanRC::RollbackCommand
          @inheritProtected()
          @module Test
        TestCommand.initialize()
        facade.registerProxy TestMemoryCollection.new LeanRC::MIGRATIONS,
          delegate: Test::TestMigration
          serializer: LeanRC::Serializer
        facade.registerProxy TestConfiguration.new LeanRC::CONFIGURATION, Test::ROOT
        class TestMigrateCommand extends LeanRC::MigrateCommand
          @inheritProtected()
          @module Test
        TestMigrateCommand.initialize()
        class ApplicationMediator extends LeanRC::Mediator
          @inheritProtected()
          @module Test
        ApplicationMediator.initialize()
        class TestApplication extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
        TestApplication.initialize()
        facade.registerMediator ApplicationMediator.new LeanRC::APPLICATION_MEDIATOR, TestApplication.new()
        forward = TestMigrateCommand.new()
        forward.initializeNotifier KEY
        command = TestCommand.new()
        command.initializeNotifier KEY
        migrationNames = command.migrationNames
        untilName = '00000000000002_second_migration'
        yield forward.migrate until: untilName
        collectionData = facade.retrieveProxy(LeanRC::MIGRATIONS)[Symbol.for '~collection']
        for migrationName, index in migrationNames
          assert.property collectionData, migrationName
          if migrationName is untilName
            steps = index + 1
            break
        steps ?= migrationNames.length
        yield command.rollback { steps }
        collectionData = facade.retrieveProxy(LeanRC::MIGRATIONS)[Symbol.for '~collection']
        assert.deepEqual collectionData, {}
        facade.remove()
        yield return
  describe '#execute', ->
    it 'should run rollback migrations via "execute"', ->
      co ->
        KEY = 'TEST_ROLLBACK_COMMAND_005'
        facade = LeanRC::Facade.getInstance KEY
        trigger = new EventEmitter
        defineMigration = (Module) ->
          class TestMigration extends LeanRC::Migration
            @inheritProtected()
            @module Module
            @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
              default: -> Test::TestMigration
            @public init: FuncG([Object, CollectionInterface], NilT),
              default: (args...) ->
                @super args...
                @type = 'TestMigration'
                return
          TestMigration.initialize()
        class Test extends LeanRC
          @inheritProtected()
          @include LeanRC::SchemaModuleMixin
          @root "#{__dirname}/config/root2"
          defineMigration @Module
          @defineMigrations()
        Test.initialize()
        class TestConfiguration extends LeanRC::Configuration
          @inheritProtected()
          @module Test
        TestConfiguration.initialize()
        class TestMemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        TestMemoryCollection.initialize()
        class TestCommand extends LeanRC::RollbackCommand
          @inheritProtected()
          @module Test
          @public @async rollback: FuncG([MaybeG StructG steps: MaybeG(Number), until: MaybeG String], UnionG NilT, Error),
            default: (options) ->
              result = yield @super options
              trigger.emit 'ROLLBACK', options
              yield return result
        TestCommand.initialize()
        facade.registerProxy TestMemoryCollection.new LeanRC::MIGRATIONS,
          delegate: Test::TestMigration
          serializer: LeanRC::Serializer
        facade.registerProxy TestConfiguration.new LeanRC::CONFIGURATION, Test::ROOT
        class TestMigrateCommand extends LeanRC::MigrateCommand
          @inheritProtected()
          @module Test
        TestMigrateCommand.initialize()
        class ApplicationMediator extends LeanRC::Mediator
          @inheritProtected()
          @module Test
        ApplicationMediator.initialize()
        class TestApplication extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
        TestApplication.initialize()
        facade.registerMediator ApplicationMediator.new LeanRC::APPLICATION_MEDIATOR, TestApplication.new()
        forward = TestMigrateCommand.new()
        forward.initializeNotifier KEY
        command = TestCommand.new()
        command.initializeNotifier KEY
        migrationNames = command.migrationNames
        untilName = '00000000000002_second_migration'
        promise = LeanRC::Promise.new (resolve, reject) ->
          trigger.once 'ROLLBACK', (options) -> resolve options
          return
        yield forward.migrate until: untilName
        collectionData = facade.retrieveProxy(LeanRC::MIGRATIONS)[Symbol.for '~collection']
        for migrationName, index in migrationNames
          if migrationName is untilName
            steps = index + 1
            break
        steps ?= migrationNames.length
        yield command.execute LeanRC::Notification.new LeanRC::MIGRATE, { steps }
        options = yield promise
        assert.deepEqual options, steps: 2
        facade.remove()
        yield return
