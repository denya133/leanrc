LeanRC = require.main.require 'lib'

module.exports = (Module)->
  class SecondMigration extends Module::TestMigration
    @inheritProtected()
    @module Module

  return SecondMigration.initialize()
