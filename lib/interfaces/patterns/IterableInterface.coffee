

module.exports = (Module)->
  {
    AnyT
    FuncG
    Interface
  } = Module::

  class IterableInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @async forEach: FuncG Function
    @virtual @async filter: FuncG Function, Array
    @virtual @async map: FuncG Function, Array
    @virtual @async reduce: FuncG [Function, AnyT], AnyT


    @initialize()
