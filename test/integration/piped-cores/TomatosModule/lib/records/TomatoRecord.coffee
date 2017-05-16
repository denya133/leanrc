

module.exports = (Module)->
  {
    Record
    TomatoEntryMixin
  } = Module::

  class TomatoRecord extends Record
    @inheritProtected()
    @include TomatoEntryMixin
    @module Module

    # business logic and before-, after- colbacks


  TomatoRecord.initialize()
