

module.exports = (Module)->
  {
    RelationConfigT, RecordInterface
    StructG, SubsetG
    RelationInverseT
  } = Module::

  RelationInverseT.define StructG {
    recordClass: SubsetG RecordInterface
    attrName: String
    relation: RelationConfigT
  }
