

module.exports = (Module)->
  {
    AnyT, JoiT
    FuncG, MaybeG, InterfaceG, SubsetG
    TransformInterface
    ComputedOptionsT
  } = Module::

  ComputedOptionsT.define InterfaceG {
    transform: MaybeG FuncG [], SubsetG TransformInterface
    validate: MaybeG FuncG [], JoiT
    get: Function
  }
