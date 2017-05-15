

module.exports = (Module)->
  {
    Stock
  } = Module::

  class CucumbersStock extends Stock
    @inheritProtected()
    @module Module

    @public entityName: String,
      default: 'cucumber'


  CucumbersStock.initialize()
