LeanRC = require.main.require 'lib'

module.exports = (Module)->
  class FirstMigration extends Module::TestMigration
    @inheritProtected()
    @module Module

  return FirstMigration.initialize()
