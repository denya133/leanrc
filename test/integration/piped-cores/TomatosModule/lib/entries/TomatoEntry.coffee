

module.exports = (Module)->
  {
    Entry
  } = Module::

  class TomatoEntry extends Entry
    @inheritProtected()
    @module Module

    @attribute name: String
    @attribute description: String


  TomatoEntry.initialize()
