{ expect, assert } = require 'chai'
sinon = require 'sinon'
RC = require 'RC'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'Migration', ->
  describe '.new', ->
    it 'should create migration instance', ->
      co ->
        migration = LeanRC::Migration.new()
        assert.lengthOf migration.steps, 0
        yield return
  describe '.createCollection', ->
    it 'should add step for create collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.createCollection 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'createCollection'
        yield return
  describe '.createEdgeCollection', ->
    it 'should add step for create edge collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.createEdgeCollection 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'createEdgeCollection'
        yield return
  describe '.addField', ->
    it 'should add step to add field in record at collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.addField 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'addField'
        yield return
  describe '.addIndex', ->
    it 'should add step to add index in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.addIndex 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'addIndex'
        yield return
  describe '.addTimestamps', ->
    it 'should add step to add timesteps in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.addTimestamps 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'addTimestamps'
        yield return
  describe '.changeCollection', ->
    it 'should add step to change collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.changeCollection 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'changeCollection'
        yield return
  describe '.changeField', ->
    it 'should add step to change field in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.changeField 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'changeField'
        yield return
  describe '.renameField', ->
    it 'should add step to rename field in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
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
    it 'should add step to rename index in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
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
    it 'should add step to rename collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
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
    it 'should add step to drop collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
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
    it 'should add step to drop edge collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
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
    it 'should add step to remove field in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
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
    it 'should add step to remove index in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
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
    it 'should add step to remove timestamps in collection', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
          @root __dirname
        Test.initialize()
        class Test::BaseMigration extends LeanRC::Migration
          @inheritProtected()
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
          @module Test
        Test::BaseMigration.initialize()
        Test::BaseMigration.reversible 'ARG_1', 'ARG_2', 'ARG_3'
        migration = Test::BaseMigration.new()
        assert.lengthOf migration.steps, 1
        assert.deepEqual migration.steps[0],
          args: [ 'ARG_1', 'ARG_2', 'ARG_3' ]
          method: 'reversible'
        yield return
