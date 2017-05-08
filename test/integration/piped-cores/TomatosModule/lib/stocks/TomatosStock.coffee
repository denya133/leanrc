

module.exports = (Module)->
  {
    Stock
  } = Module::

  class TomatosStock extends Stock
    @inheritProtected()
    @module Module

    @public entityName: String,
      default: 'tomato'


  TomatosStock.initialize()
