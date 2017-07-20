

LeanRC = require.main.require 'lib'


class Cucumbers extends LeanRC
  @inheritProtected()

  @root __dirname

  require('./mixins/CucumberEntryMixin') @Module

  require('./records/CucumberRecord') @Module

  require('./resources/CucumbersResource') @Module

  require('./ApplicationRouter') @Module


module.exports = Cucumbers.initialize().freeze()
