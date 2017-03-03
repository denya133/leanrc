RC = require 'RC'

# так как рекорд будет работать с простыми структурами данных в памяти, он не зависит от платформы.
# если ему надо будет взаимодействовать с платформозависимой логикой - он будет делать это через прокси, но не напрямую (как в эмбере со стором)

module.exports = (LeanRC)->
  class LeanRC::RecordInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual collection: LeanRC::CollectionInterface

    # объявлю пока здесь, чтобы не забыть
    @private internalRecord: Object # тип и формат хранения надо обдумать. Это инкапсулированные данные последнего сохраненного состояния из базы - нужно для функционала вычисления дельты изменений. (относительно изменений которые проведены над объектом но еще не сохранены в базе данных - хранилище.)

    # под вопросом ??????
    # @public @static schema: JoiSchema
    # @public @static customFilters: Function, [statement], -> NILL
    # @private @static _customFilters: Function, [], -> Object
    # @private @static _parentClassesNames: Function, [], -> Array
    # @public @static collectionName: Function, [], -> String #adb
    # @public @static collectionNameInDB: Function, [[String, NILL]], -> String #adb
    # @public @static collectionPrefix: Function, [], -> String #adb
    # @public @static getLocksFor: Function, [[String, Array], Array], ->Object #adb

    # под вопросом ??????
    @public @static parseModelName: Function, [String], -> Array
    @public @static findModelByName: Function, [String], -> Array
    @public findModelByName: Function, [String], -> Array
    @public parseModelName: Function, [String], -> Array



    # под вопросом ??????
    @public validate: Function, [], -> SELF
    # @public beforeValidate: Function, [], -> NILL
    # @public afterValidate: Function, [], -> NILL
    @public save: Function, [], -> SELF
    # @public beforeSave: Function, [], -> NILL
    # @public afterSave: Function, [ANY], -> ANY # any type
    @public create: Function, [], -> SELF
    # @public beforeCreate: Function, [], -> NILL
    # @public afterCreate: Function, [ANY], -> ANY # any type
    @public update: Function, [], -> SELF
    # @public beforeUpdate: Function, [], -> NILL
    # @public afterUpdate: Function, [ANY], -> ANY # any type
    @public delete: Function, [], -> SELF
    # @public beforeDelete: Function, [], -> NILL
    # @public afterDelete: Function, [ANY], -> ANY # any type
    @public destroy: Function, [], -> SELF
    # @public beforeDestroy: Function, [], -> NILL
    # @public afterDestroy: Function, [], -> NILL

    # здесь не декларируются before/after хуки, потому что их использование относится сугубо к реализации, но не к спецификации интерфейса как такового.

    # под вопросом ????
    @public recordHasBeenChanged: Function, [], -> NILL
    @public updateEdges: Function, [ANY], -> ANY # any type



    # под вопросом ??????
    @private _resetAttributes: Function, [Object], -> ModelInterface
    @public getSnapshot: Function, [], -> Object
    @private _forClient: Function, [Object], -> Object

    # под вопросом ?????? # возможно надо это определять в сериалайзере
    @public @static serializableAttributes: Function, [], -> Object
    @public @static serializeFromBatch: Function, [Object], -> Object
    @public @static serializeFromClient: Function, [Object], -> Object
    @public serializeForClient: Function, [Object], -> Object



    # @private @static __attrs: Object
    # @private @static _attrs: Function, [], -> Object
    @public @static @virtual attributes: Function,
      args: []
      return: Object
    # @private @static __edges: Object
    # @private @static _edges: Function, [], -> Object
    @public @static @virtual edges: Function,
      args: []
      return: Object
    # @private @static __props: Object
    # @private @static _props: Function, [], -> Object
    @public @static @virtual properties: Function,
      args: []
      return: Object
    # @private @static __comps: Object
    # @private @static _comps: Function, [], -> Object
    @public @static @virtual computeds: Function,
      args: []
      return: Object

    @public @static @virtual attribute: Function,
      args: [String, Object, Object] #name, schema, Object
      return: RC::Constants.NILL
    @public @static @virtual attr: Function,
      args: [String, Object, Object] #name, schema, Object
      return: RC::Constants.NILL
    @public @static @virtual property: Function,
      args: [String, Object] #name, Object
      return: RC::Constants.NILL
    @public @static @virtual prop: Function,
      args: [String, Object] #name, Object
      return: RC::Constants.NILL
    @public @static @virtual computed: Function,
      args: [String, Object, Function] #name, opts, lambda
      return: RC::Constants.NILL
    @public @static @virtual comp: Function,
      args: [String, Object, Function] #name, opts, lambda
      return: RC::Constants.NILL
    @public @static @virtual belongsTo: Function,
      args: [String, Object, Object] # name, schema, opts
      return: RC::Constants.NILL
    @public @static @virtual hasMany: Function,
      args: [String, Object] #name, opts
      return: RC::Constants.NILL
    @public @static @virtual hasOne: Function,
      args: [String, Object] #name, opts
      return: RC::Constants.NILL
    @public @static @virtual new: Function,
      args: [Object] #attributes
      return: LeanRC::RecordInterface
    @public @static @virtual inverseFor: Function,
      args: [String]
      return: Object # Cucumber.inverseFor 'tomato' #-> {type: App::Tomato, name: 'cucumbers', kind: 'hasMany'}
    @public @static @virtual validate: Function, # из рельсов, но что внутри делать пока не понятно.
      args: [String, Object] #attribute, options
      return: RC::Constants.NILL

    @public @virtual _key: String
    @public @virtual _rev: String
    @public @virtual _type: String
    @public @virtual isHidden: Boolean
    @public @virtual createdAt: Date
    @public @virtual updatedAt: Date
    @public @virtual id: String
    @public @virtual rev: String
    @public @virtual type: String

    @public @virtual attributes: Function, # метод должен вернуть список атрибутов данного рекорда.
      args: []
      return: Array
    @public @virtual clone: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual copy: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual deepCopy: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual decrement: Function,
      args: [String, [Number, RC::Constants.NILL]] #attribute, step
      return: LeanRC::RecordInterface
    @public @virtual increment: Function,
      args: [String, [Number, RC::Constants.NILL]] #attribute, step
      return: LeanRC::RecordInterface
    @public @virtual toggle: Function,
      args: [String] #attribute
      return: LeanRC::RecordInterface
    @public @virtual touch: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual updateAttribute: Function,
      args: [String, RC::Constants.ANY] #name, value
      return: LeanRC::RecordInterface
    @public @virtual updateAttributes: Function,
      args; [Object] #attributes
      return: LeanRC::RecordInterface
    @public @virtual isNew: Function,
      args: []
      return: Boolean
    @public @virtual reload: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual changedAttributes: Function,
      args: []
      return: Object # { isAdmin: [undefined, true], name: [undefined, 'Tomster'] }
    @public @virtual resetAttribute: Function,
      args: [String]
      return: RC::Constants.NILL
    @public @virtual rollbackAttributes: Function,
      args: []
      return: RC::Constants.NILL


  return LeanRC::RecordInterface.initialize()
