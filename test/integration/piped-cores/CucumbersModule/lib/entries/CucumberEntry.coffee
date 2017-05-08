

module.exports = (Module)->
  {
    Entry
  } = Module::

  class CucumberEntry extends Entry
    @inheritProtected()
    @module Module

    @attribute name: String
    @attribute description: String


  CucumberEntry.initialize()
