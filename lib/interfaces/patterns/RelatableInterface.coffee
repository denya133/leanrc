

module.exports = (Module)->
  {
    PropertyDefinitionT, RelationOptionsT, RelationConfigT, RelationInverseT
    FuncG, StructG, SubsetG, DictG
    RecordInterface
    Interface
  } = Module::

  class RelatableInterface extends Interface
    @inheritProtected()
    @module Module

    @virtual @static relatedTo: FuncG [PropertyDefinitionT, RelationOptionsT]
    @virtual @static belongsTo: FuncG [PropertyDefinitionT, RelationOptionsT]
    @virtual @static hasMany: FuncG [PropertyDefinitionT, RelationOptionsT]
    @virtual @static hasOne: FuncG [PropertyDefinitionT, RelationOptionsT]
    @virtual @static inverseFor: FuncG String, RelationInverseT
    @virtual @static relations: DictG String, RelationConfigT


    @initialize()
