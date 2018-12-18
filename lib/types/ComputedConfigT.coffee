

module.exports = (Module)->
  {
    JoiT
    FuncG, InterfaceG, SubsetG
    TransformInterface
    ComputedConfigT
  } = Module::

  ComputedConfigT.define InterfaceG {
    transform: FuncG [], SubsetG TransformInterface
    validate: FuncG [], JoiT
    get: Function
  }
