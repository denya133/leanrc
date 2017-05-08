

module.exports = (Module)->
  {
    Record
  } = Module::

  class TomatoRecord extends Record
    @inheritProtected()
    @module Module

    @attribute name: String
    @attribute description: String


  TomatoRecord.initialize()
