

LeanRC = require.main.require 'lib'


class Tomatos extends LeanRC
  @inheritProtected()

  @root __dirname

  require('./mixins/TomatoEntryMixin') @Module

  require('./records/TomatoRecord') @Module
  require('./records/CucumberRecord') @Module

  require('./stocks/TomatosStock') @Module

  require('./ApplicationRouter') @Module


module.exports = Tomatos.initialize().freeze()
