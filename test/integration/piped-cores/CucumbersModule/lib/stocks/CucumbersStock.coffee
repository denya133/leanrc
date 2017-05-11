

module.exports = (Module)->
  {
    Stock
  } = Module::

  class CucumbersStock extends Stock
    @inheritProtected()
    @module Module

    @chains ['list']

    @public entityName: String,
      default: 'cucumber'

    @public @async list: Function,
      default: (args...)->
        yield @super args...



  CucumbersStock.initialize()
