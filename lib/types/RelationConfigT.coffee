

module.exports = (Module)->
  {
    AsyncFunctionT
    MaybeG, StructG, TupleG, EnumG
    RelationConfigT
  } = Module::

  RelationConfigT.define MaybeG StructG {
    refKey: String
    attr: MaybeG String
    inverse: String
    inverseType: MaybeG String
    relation: EnumG 'relatedTo', 'belongsTo', 'hasMany', 'hasOne'
    recordName: Function
    collectionName: Function
    through: MaybeG TupleG String, StructG by: String
    get: AsyncFunctionT
  }
