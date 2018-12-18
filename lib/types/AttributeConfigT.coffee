

module.exports = (Module)->
  {
    AnyT, JoiT
    FuncG, InterfaceG, SubsetG, MaybeG
    TransformInterface
    AttributeConfigT
  } = Module::

  AttributeConfigT.define InterfaceG {
    default: MaybeG AnyT
    transform: FuncG [], SubsetG TransformInterface
    validate: FuncG [], JoiT
    set: Function
  }
