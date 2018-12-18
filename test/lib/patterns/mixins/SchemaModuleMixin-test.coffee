{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'SchemaModuleMixin', ->
  describe '.defineMigrations', ->
    it 'should create configuration instance', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
          @include LeanRC::SchemaModuleMixin
          @root "#{__dirname}/config/root"
          @defineMigrations()
        Test.initialize()
        assert.deepEqual Test::MIGRATION_NAMES, [
          '01_migration', '02_migration', '03_migration'
        ]
        assert.instanceOf Test::Migration1::, LeanRC::Migration
        assert.instanceOf Test::Migration2::, LeanRC::Migration
        assert.instanceOf Test::Migration3::, LeanRC::Migration
        yield return
