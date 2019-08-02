

module.exports = (Module)->
  {
    AnyT
    FuncG, StructG, MaybeG
    ContextInterface
    ResourceInterface
    Interface
  } = Module::

  class ApplicationInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @static NAME: String

    @virtual isLightweight: Boolean
    @virtual context: MaybeG ContextInterface

    @virtual start: Function
    @virtual finish: Function
    @virtual @async migrate: FuncG [MaybeG StructG until: MaybeG String]
    @virtual @async rollback: FuncG [MaybeG StructG {
      steps: MaybeG(Number), until: MaybeG String
    }]
    @virtual @async run: FuncG [String, MaybeG AnyT], MaybeG(AnyT)
    @virtual @async execute: FuncG [String, StructG({
      context: ContextInterface, reverse: String
    }), String], StructG {
      result: MaybeG(AnyT), resource: ResourceInterface
    }


    @initialize()
