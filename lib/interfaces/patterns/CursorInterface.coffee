

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, MaybeG
    CollectionInterface
    CursorInterface: CursorInterfaceDef
    Interface
  } = Module::

  class CursorInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual isClosed: Boolean

    @virtual setCollection: FuncG CollectionInterface, CursorInterfaceDef

    @virtual setIterable: FuncG AnyT, CursorInterfaceDef

    @virtual @async toArray: FuncG [], Array

    @virtual @async next: FuncG [], MaybeG AnyT

    @virtual @async hasNext: FuncG [], Boolean

    @virtual @async close: Function

    @virtual @async count: FuncG [], Number

    @virtual @async forEach: FuncG Function, NilT

    @virtual @async map: FuncG Function, Array

    @virtual @async filter: FuncG Function, Array

    @virtual @async find: FuncG Function, AnyT

    @virtual @async compact: FuncG [], Array

    @virtual @async reduce: FuncG [Function, AnyT], AnyT

    @virtual @async first: FuncG [], MaybeG  AnyT


    @initialize()
