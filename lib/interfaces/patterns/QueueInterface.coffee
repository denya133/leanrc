

module.exports = (Module)->
  {
    AnyT
    FuncG, MaybeG, UnionG, ListG
    ResqueInterface
    Interface
  } = Module::

  class QueueInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual resque: ResqueInterface
    @virtual name: String
    @virtual concurrency: Number

    @virtual @async delay: FuncG [String, AnyT, MaybeG Number], UnionG String, Number

    @virtual @async push: FuncG [String, AnyT, MaybeG Number], UnionG String, Number

    @virtual @async get: FuncG [UnionG String, Number], MaybeG Object

    @virtual @async delete: FuncG [UnionG String, Number], Boolean

    @virtual @async abort: FuncG [UnionG String, Number]

    @virtual @async all: FuncG [MaybeG String], ListG Object

    @virtual @async pending: FuncG [MaybeG String], ListG Object

    @virtual @async progress: FuncG [MaybeG String], ListG Object

    @virtual @async completed: FuncG [MaybeG String], ListG Object

    @virtual @async failed: FuncG [MaybeG String], ListG Object


    @initialize()
