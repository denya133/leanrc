

module.exports = (Module)->
  {
    MaybeG, StructG, TupleG, InterfaceG
    RelationOptionsT
  } = Module::

  RelationOptionsT.define MaybeG InterfaceG {
    refKey: MaybeG String
    attr: MaybeG String
    inverse: MaybeG String
    inverseType: MaybeG String
    recordName: MaybeG Function
    collectionName: MaybeG Function
    through: MaybeG TupleG String, StructG by: String
  }
