

module.exports = (Module)->
  {
    JoiT, AsyncFunctionT
    FuncG, MaybeG, StructG, TupleG, EnumG
    EmbedConfigT
  } = Module::

  EmbedConfigT.define MaybeG StructG {
    refKey: String
    inverse: String
    inverseType: MaybeG String
    attr: MaybeG String
    embedding: EnumG 'relatedEmbed', 'relatedEmbeds', 'hasEmbed', 'hasEmbeds'
    through: MaybeG TupleG String, StructG by: String
    putOnly: Boolean
    loadOnly: Boolean
    recordName: Function
    collectionName: Function
    validate: FuncG [], JoiT
    load: AsyncFunctionT
    put: AsyncFunctionT
    restore: AsyncFunctionT
    replicate: Function
  }
