{CucumberEntry} = require('../../../CucumbersModule')::


module.exports = (Module)->
  class CucumberRecord extends CucumberEntry
    @inheritProtected()
    @module Module


  CucumberRecord.initialize()
