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
