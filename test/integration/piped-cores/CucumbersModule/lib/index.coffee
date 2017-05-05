

LeanRC = require.main.require 'lib'


class Cucumbers extends LeanRC
  @inheritProtected()

  @root __dirname

  require('./entries/CucumberEntry') @Module

  require('./records/CucumberRecord') @Module

  require('./stocks/CucumbersStock') @Module

  require('./ApplicationRouter') @Module


module.exports = Cucumbers.initialize().freeze()
