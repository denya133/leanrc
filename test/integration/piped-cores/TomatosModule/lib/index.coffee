

LeanRC = require.main.require 'lib'


class Tomatos extends LeanRC
  @inheritProtected()

  @root __dirname

  require('./entries/TomatoEntry') @Module

  require('./records/TomatoRecord') @Module

  require('./ApplicationRouter') @Module


module.exports = Tomatos.initialize().freeze()
