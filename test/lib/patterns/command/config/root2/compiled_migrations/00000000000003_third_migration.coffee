LeanRC = require.main.require 'lib'

module.exports = (Module)->
  class ThirdMigration extends Module::TestMigration
    @inheritProtected()
    @module Module

  return ThirdMigration.initialize()
