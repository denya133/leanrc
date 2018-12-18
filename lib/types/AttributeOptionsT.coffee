

module.exports = (Module)->
  {
    AnyT, JoiT
    FuncG, MaybeG, InterfaceG, SubsetG
    TransformInterface
    AttributeOptionsT
  } = Module::

  AttributeOptionsT.define MaybeG InterfaceG {
    default: MaybeG AnyT
    transform: MaybeG FuncG [], SubsetG TransformInterface
    validate: MaybeG FuncG [], JoiT
    set: MaybeG Function
  }
