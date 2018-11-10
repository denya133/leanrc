

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG
    Interface
  } = Module::

  class IterableInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @async forEach: FuncG Function, NilT
    @virtual @async filter: FuncG Function, Array
    @virtual @async map: FuncG Function, Array
    @virtual @async reduce: FuncG [Function, AnyT], AnyT


    @initialize()
