{CucumberEntryMixin} = require('../../../CucumbersModule')::


module.exports = (Module)->
  {
    Record
  } = Module::

  class CucumberRecord extends Record
    @inheritProtected()
    @include CucumberEntryMixin
    @module Module

    # business logic and before-, after- colbacks

  CucumberRecord.initialize()
