# так как рекорд будет работать с простыми структурами данных в памяти, он не зависит от платформы.
# если ему надо будет взаимодействовать с платформозависимой логикой - он будет делать это через прокси, но не напрямую (как в эмбере со стором)


module.exports = (Module)->
  {
    AnyT, JoiT, PropertyDefinitionT
    AttributeOptionsT, ComputedOptionsT
    AttributeConfigT, ComputedConfigT
    FuncG, TupleG, MaybeG, SubsetG, DictG, ListG
    CollectionInterface
    RecordInterface: RecordInterfaceDef
    TransformInterface
  } = Module::

  class RecordInterface extends TransformInterface
    @inheritProtected()
    @module Module

    @virtual collection: CollectionInterface

    @virtual @static schema: JoiT

    @virtual @static @async normalize: FuncG [MaybeG(Object), CollectionInterface], RecordInterfaceDef

    @virtual @static @async serialize: FuncG [MaybeG RecordInterfaceDef], MaybeG Object

    @virtual @static @async recoverize: FuncG [MaybeG(Object), CollectionInterface], MaybeG RecordInterfaceDef

    @virtual @static objectize: FuncG [MaybeG(RecordInterfaceDef), MaybeG Object], MaybeG Object

    @virtual @static makeSnapshot: FuncG [MaybeG RecordInterfaceDef], MaybeG Object

    @virtual @static parseRecordName: FuncG String, TupleG String, String

    @virtual parseRecordName: FuncG String, TupleG String, String

    @virtual @static findRecordByName: FuncG String, SubsetG RecordInterfaceDef

    @virtual findRecordByName: FuncG String, SubsetG RecordInterfaceDef

    ###
      @customFilter ->
        reason:
          '$eq': (value)->
            # string of some aql code for example
          '$neq': (value)->
            # string of some aql code for example
    ###
    @virtual @static customFilters: Object

    @virtual @static customFilter: FuncG Function

    @virtual @static parentClassNames: FuncG [MaybeG SubsetG RecordInterfaceDef], ListG String

    @virtual @static attributes: DictG String, AttributeConfigT
    @virtual @static computeds: DictG String, ComputedConfigT

    @virtual @static attribute: FuncG [PropertyDefinitionT, AttributeOptionsT]

    @virtual @static computed: FuncG [PropertyDefinitionT, ComputedOptionsT]

    @virtual @static new: FuncG [Object, CollectionInterface], RecordInterfaceDef

    @virtual @async save: FuncG [], RecordInterfaceDef

    @virtual @async create: FuncG [], RecordInterfaceDef

    @virtual @async update: FuncG [], RecordInterfaceDef

    @virtual @async delete: FuncG [], RecordInterfaceDef

    @virtual @async destroy: Function

    # NOTE: метод должен вернуть список атрибутов данного рекорда.
    @virtual attributes: FuncG [], Object

    # NOTE: в оперативной памяти создается клон рекорда, НО с другим id
    @virtual @async clone: FuncG [], RecordInterfaceDef

    # NOTE: в коллекции создается копия рекорда, НО с другим id
    @virtual @async copy: FuncG [], RecordInterfaceDef

    @virtual @async decrement: FuncG [String, MaybeG Number], RecordInterfaceDef

    @virtual @async increment: FuncG [String, MaybeG Number], RecordInterfaceDef

    @virtual @async toggle: FuncG String, RecordInterfaceDef

    @virtual @async touch: FuncG [], RecordInterfaceDef

    @virtual @async updateAttribute: FuncG [String, MaybeG AnyT], RecordInterfaceDef

    @virtual @async updateAttributes: FuncG Object, RecordInterfaceDef

    @virtual @async isNew: FuncG [], Boolean

    @virtual @async reload: FuncG [], RecordInterfaceDef

    @virtual @async changedAttributes: FuncG [], DictG String, Array

    @virtual @async resetAttribute: FuncG String

    @virtual @async rollbackAttributes: Function


    @initialize()
