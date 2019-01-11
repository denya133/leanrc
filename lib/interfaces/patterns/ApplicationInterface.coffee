

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

    @virtual finish: Function
    @virtual @async migrate: FuncG [MaybeG StructG until: MaybeG String]
    @virtual @async rollback: FuncG [MaybeG StructG {
      steps: MaybeG(Number), until: MaybeG String
    }]
    @virtual @async run: FuncG [String, AnyT], AnyT
    @virtual @async execute: FuncG [String, StructG({
      context: ContextInterface, reverse: String
    }), String], StructG {
      result: AnyT, resource: ResourceInterface
    }


    @initialize()
