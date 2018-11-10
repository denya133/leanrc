

module.exports = (Module)->
  {
    MaybeG, StructG, TupleG
    EmbedOptionsT
  } = Module::

  EmbedOptionsT.define MaybeG StructG {
    refKey: MaybeG String
    inverse: MaybeG String
    attr: MaybeG String
    through: MaybeG TupleG String, StructG by: String
    putOnly: MaybeG Boolean
    loadOnly: MaybeG Boolean
    recordName: MaybeG Function
    collectionName: MaybeG Function    
  }
