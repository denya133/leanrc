

module.exports = (Module)->
  {
    RecordInterface
    StructG, SubsetG
    RelationInverseT
  } = Module::

  RelationInverseT.define StructG {
    recordClass: SubsetG RecordInterface
    attrName: String
    relation: String
  }
