LeanRC = require.main.require 'lib'

module.exports = (Module)->
  class FirstMigration extends LeanRC::Migration
    @inheritProtected()
    @module Module

  return FirstMigration.initialize()
