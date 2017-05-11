LeanRC = require.main.require 'lib'

module.exports = (Module)->
  class ThirdMigration extends LeanRC::Migration
    @inheritProtected()
    @module Module

  return ThirdMigration.initialize()
