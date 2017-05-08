{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'MemoryMigrationMixin', ->
  describe '.new', ->
    it 'should create migration instance', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
        Test::BaseMigration.initialize()
        migration = Test::BaseMigration.new()
        yield return
  describe '#createCollection', ->
    it 'should apply step for create collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
          @createCollection 'TestCollection'
        Test::BaseMigration.initialize()
        migration = Test::BaseMigration.new()
        spyCreateCollection = sinon.spy migration, 'createCollection'
        yield migration.up()
        assert.isTrue spyCreateCollection.calledWith 'TestCollection'
        yield return
  describe '#createEdgeCollection', ->
    it 'should apply step for create edge collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
          @createEdgeCollection 'TestEdgeCollection'
        Test::BaseMigration.initialize()
        migration = Test::BaseMigration.new()
        spyCreateCollection = sinon.spy migration, 'createEdgeCollection'
        yield migration.up()
        assert.isTrue spyCreateCollection.calledWith 'TestEdgeCollection'
        yield return
  describe '#addField', ->
    it 'should apply step to add field in record at collection', ->
      co ->
        KEY = 'TEST_MEMORY_MIGRATION_MIXIN_001'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attr 'test': String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
          @addField 'Test', 'test',
            default: 'Test1'
        Test::BaseMigration.initialize()
        class Test::MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::MemoryCollection.initialize()
        facade.registerProxy Test::MemoryCollection.new 'TestCollection',
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
        collection = facade.retrieveProxy 'TestCollection'
        yield collection.create _key: 1
        yield collection.create _key: 2
        yield collection.create _key: 3
        migration = Test::BaseMigration.new {}, collection
        yield migration.up()
        for own id, doc of collection[Symbol.for '~collection']
          assert.propertyVal doc, 'test', 'Test1'
        yield return
  describe '#addIndex', ->
    it 'should apply step to add index in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
          @addIndex 'ARG_1', 'ARG_2', 'ARG_3'
        Test::BaseMigration.initialize()
        migration = Test::BaseMigration.new()
        spyAddIndex = sinon.spy migration, 'addIndex'
        yield migration.up()
        assert.isTrue spyAddIndex.calledWith 'ARG_1', 'ARG_2', 'ARG_3'
        yield return
  describe '#addTimestamps', ->
    it 'should apply step to add timesteps in collection', ->
      co ->
        KEY = 'TEST_MEMORY_MIGRATION_MIXIN_002'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attr 'test': String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::MemoryCollection.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
          @addTimestamps 'Test'
        Test::BaseMigration.initialize()
        facade.registerProxy Test::MemoryCollection.new 'TestCollection',
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
        collection = facade.retrieveProxy 'TestCollection'
        yield collection.create _key: 1
        yield collection.create _key: 2
        yield collection.create _key: 3
        migration = Test::BaseMigration.new {}, collection
        yield migration.up()
        for own id, doc of collection[Symbol.for '~collection']
          assert.property doc, 'createdAt'
          assert.property doc, 'updatedAt'
          assert.property doc, 'updatedAt'
        yield return
  describe '#changeCollection', ->
    it 'should apply step to change collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
          @changeCollection 'ARG_1', 'ARG_2', 'ARG_3'
        Test::BaseMigration.initialize()
        migration = Test::BaseMigration.new()
        spyChangeCollection = sinon.spy migration, 'changeCollection'
        yield migration.up()
        assert.isTrue spyChangeCollection.calledWith 'ARG_1', 'ARG_2', 'ARG_3'
        yield return
  describe '#changeField', ->
    it 'should apply step to change field in collection', ->
      co ->
        KEY = 'TEST_MEMORY_MIGRATION_MIXIN_003'
        facade = LeanRC::Facade.getInstance KEY
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
          @attr 'test': String
          @public init: Function,
            default: ->
              @super arguments...
              @_type = 'Test::TestRecord'
        Test::TestRecord.initialize()
        class Test::MemoryCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::MemoryCollectionMixin
          @module Test
        Test::MemoryCollection.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
          @changeField 'Test', 'test', type: LeanRC::Migration::SUPPORTED_TYPES.integer
        Test::BaseMigration.initialize()
        facade.registerProxy Test::MemoryCollection.new 'TestCollection',
          delegate: Test::TestRecord
          serializer: LeanRC::Serializer
        collection = facade.retrieveProxy 'TestCollection'
        yield collection.create test: '42'
        yield collection.create test: '42'
        yield collection.create test: '42'
        migration = Test::BaseMigration.new {}, collection
        yield migration.up()
        for own id, doc of collection[Symbol.for '~collection']
          assert.propertyVal doc, 'test', 42
        yield return
  ###
  describe '#renameField', ->
    it 'should apply step to rename field in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.renameField 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'renameField'
        yield return
  describe '.renameIndex', ->
    it 'should apply step to rename index in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.renameIndex 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'renameIndex'
        yield return
  describe '.renameCollection', ->
    it 'should apply step to rename collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.renameCollection 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'renameCollection'
        yield return
  describe '.dropCollection', ->
    it 'should apply step to drop collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.dropCollection 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'dropCollection'
        yield return
  describe '.dropEdgeCollection', ->
    it 'should apply step to drop edge collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.dropEdgeCollection 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'dropEdgeCollection'
        yield return
  describe '.removeField', ->
    it 'should apply step to remove field in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.removeField 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'removeField'
        yield return
  describe '.removeIndex', ->
    it 'should apply step to remove index in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.removeIndex 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'removeIndex'
        yield return
  describe '.removeTimestamps', ->
    it 'should apply step to remove timestamps in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.removeTimestamps 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'removeTimestamps'
        yield return
  describe '.reversible', ->
    it 'should add reversible step', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.reversible 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'reversible'
        yield return
  describe '#execute', ->
    it 'should run generator closure with some code', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
        Test::BaseMigration.initialize()
        migration = Test::BaseMigration.new()
        spyExecute = sinon.spy -> yield return
        yield migration.execute spyExecute
        assert.isTrue spyExecute.called
        yield return
  describe '.change', ->
    it 'should run closure with some code', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
        Test::BaseMigration.initialize()
        spyChange = sinon.spy ->
        Test::BaseMigration.change spyChange
        assert.isTrue spyChange.called
        yield return
  describe '#up', ->
    it 'should run steps in forward direction', ->
      co ->
        spyReversibleUp = sinon.spy -> yield return
        spyCreateCollection = sinon.spy -> yield return
        spyAddField = sinon.spy -> yield return
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
          @reversible ({ up, down }) ->
            yield up spyReversibleUp
            yield @createCollection 'TEST_COLLECTION'
            yield return
          @addField 'TEST_FIELD'
          @public @async createCollection: Function,
            default: spyCreateCollection
          @public @async addField: Function,
            default: spyAddField
        Test::BaseMigration.initialize()
        migration = Test::BaseMigration.new()
        yield migration.up()
        assert.isTrue spyReversibleUp.called
        assert.isTrue spyCreateCollection.calledAfter spyReversibleUp
        assert.isTrue spyAddField.calledAfter spyCreateCollection
        assert.equal spyCreateCollection.args[0][0], 'TEST_COLLECTION'
        assert.equal spyAddField.args[0][0], 'TEST_FIELD'
        yield return
  describe '#down', ->
    it 'should run steps in backward direction', ->
      co ->
        spyReversibleDown = sinon.spy -> yield return
        spyCreateCollection = sinon.spy -> yield return
        spyRenameIndex = sinon.spy -> yield return
        spyRemoveField = sinon.spy -> yield return
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
          @reversible ({ up, down }) ->
            yield down spyReversibleDown
            yield @createCollection 'TEST_COLLECTION'
            yield return
          @addField 'TEST_FIELD'
          @renameIndex 'TEST_INDEX'
          @public @async createCollection: Function,
            default: spyCreateCollection
          @public @async renameIndex: Function,
            default: spyRenameIndex
          @public @async removeField: Function,
            default: spyRemoveField
        Test::BaseMigration.initialize()
        migration = Test::BaseMigration.new()
        yield migration.down()
        assert.isTrue spyRenameIndex.called
        assert.isTrue spyRemoveField.calledAfter spyRenameIndex
        assert.isTrue spyReversibleDown.calledAfter spyRemoveField
        assert.isTrue spyCreateCollection.calledAfter spyReversibleDown
        assert.equal spyCreateCollection.args[0][0], 'TEST_COLLECTION'
        assert.equal spyRemoveField.args[0][0], 'TEST_FIELD'
        yield return
  describe '.up', ->
    it 'should replace forward stepping caller', ->
      co ->
        spyUp = sinon.spy -> yield return
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
          @up spyUp
        Test::BaseMigration.initialize()
        migration = Test::BaseMigration.new()
        assert.isFalse spyUp.called
        yield migration.up()
        assert.isTrue spyUp.called
        yield return
  describe '.down', ->
    it 'should replace forward stepping caller', ->
      co ->
        spyDown = sinon.spy -> yield return
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
          @down spyDown
        Test::BaseMigration.initialize()
        migration = Test::BaseMigration.new()
        assert.isFalse spyDown.called
        yield migration.down()
        assert.isTrue spyDown.called
        yield return
  describe '#migrate', ->
    it 'should run steps in forward direction', ->
      co ->
        spyReversibleUp = sinon.spy -> yield return
        spyCreateCollection = sinon.spy -> yield return
        spyAddField = sinon.spy -> yield return
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
          @reversible ({ up, down }) ->
            yield up spyReversibleUp
            yield @createCollection 'TEST_COLLECTION'
            yield return
          @addField 'TEST_FIELD'
          @public @async createCollection: Function,
            default: spyCreateCollection
          @public @async addField: Function,
            default: spyAddField
        Test::BaseMigration.initialize()
        migration = Test::BaseMigration.new()
        yield migration.migrate Test::BaseMigration::UP
        assert.isTrue spyReversibleUp.called
        assert.isTrue spyCreateCollection.calledAfter spyReversibleUp
        assert.isTrue spyAddField.calledAfter spyCreateCollection
        assert.equal spyCreateCollection.args[0][0], 'TEST_COLLECTION'
        assert.equal spyAddField.args[0][0], 'TEST_FIELD'
        yield return
    it 'should run steps in backward direction', ->
      co ->
        spyReversibleDown = sinon.spy -> yield return
        spyCreateCollection = sinon.spy -> yield return
        spyRenameIndex = sinon.spy -> yield return
        spyRemoveField = sinon.spy -> yield return
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @include LeanRC::MemoryMigrationMixin
          @module Test
          @reversible ({ up, down }) ->
            yield down spyReversibleDown
            yield @createCollection 'TEST_COLLECTION'
            yield return
          @addField 'TEST_FIELD'
          @renameIndex 'TEST_INDEX'
          @public @async createCollection: Function,
            default: spyCreateCollection
          @public @async renameIndex: Function,
            default: spyRenameIndex
          @public @async removeField: Function,
            default: spyRemoveField
        Test::BaseMigration.initialize()
        migration = Test::BaseMigration.new()
        yield migration.migrate Test::BaseMigration::DOWN
        assert.isTrue spyRenameIndex.called
        assert.isTrue spyRemoveField.calledAfter spyRenameIndex
        assert.isTrue spyReversibleDown.calledAfter spyRemoveField
        assert.isTrue spyCreateCollection.calledAfter spyReversibleDown
        assert.equal spyCreateCollection.args[0][0], 'TEST_COLLECTION'
        assert.equal spyRemoveField.args[0][0], 'TEST_FIELD'
        yield return
  ###
