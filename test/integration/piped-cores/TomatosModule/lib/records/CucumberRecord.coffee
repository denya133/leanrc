

module.exports = (Module)->
  {
    Record
  } = Module::

  class CucumberRecord extends Record
    @inheritProtected()
    @module Module

    # Place for attributes and computeds definitions
    @attribute name: String
    @attribute description: String

    # business logic and before-, after- colbacks

  CucumberRecord.initialize()
