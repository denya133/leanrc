

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
        r = yield @super args...
        console.log '?????LLList', r
        yield return r



  CucumbersStock.initialize()
