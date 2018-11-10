

module.exports = (Module)->
  {
    MaybeG, StructG, TupleG
    RelationOptionsT
  } = Module::

  RelationOptionsT.define MaybeG StructG {
    refKey: MaybeG String
    attr: MaybeG String
    inverse: MaybeG String
    recordName: MaybeG Function
    collectionName: MaybeG Function
    through: MaybeG TupleG String, StructG by: String
  }
