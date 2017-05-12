

module.exports = (Module)->
  {
    Stock
  } = Module::

  class CucumbersStock extends Stock
    @inheritProtected()
    @module Module

    @public entityName: String,
      default: 'cucumber'

    @public @async list: Function,
      default: (args...)->
        yield @super args...


  CucumbersStock.initialize()
