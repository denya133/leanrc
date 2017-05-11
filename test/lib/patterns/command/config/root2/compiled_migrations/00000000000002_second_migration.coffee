LeanRC = require.main.require 'lib'

module.exports = (Module)->
  class SecondMigration extends LeanRC::Migration
    @inheritProtected()
    @module Module

  return SecondMigration.initialize()
