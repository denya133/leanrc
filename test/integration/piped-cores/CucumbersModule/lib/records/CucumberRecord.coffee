

module.exports = (Module)->
  {
    Record
  } = Module::

  class CucumberRecord extends Record
    @inheritProtected()
    @module Module

    @attribute name: String
    @attribute description: String


  CucumberRecord.initialize()
