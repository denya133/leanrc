RC = require 'RC'

# так как рекорд будет работать с простыми структурами данных в памяти, он не зависит от платформы.
# если ему надо будет взаимодействовать с платформозависимой логикой - он будет делать это через прокси, но не напрямую (как в эмбере со стором)

module.exports = (LeanRC)->
  class LeanRC::RecordInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual collection: LeanRC::CollectionInterface

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

    @private @static __attrs: Object
    @private @static _attrs: Function, [], -> Object
    @public @static attributes: Function, [], -> Object
    @private @static __edges: Object
    @private @static _edges: Function, [], -> Object
    @public @static edges: Function, [], -> Object
    @private @static __props: Object
    @private @static _props: Function, [], -> Object
    @public @static properties: Function, [], -> Object
    @private @static __comps: Object
    @private @static _comps: Function, [], -> Object
    @public @static computeds: Function, [], -> Object

    @public @static attribute: Function, [name, schema, Object], -> NILL
    @public @static attr: Function, [name, schema, Object], -> NILL
    @public @static property: Function, [name, Object], -> NILL
    @public @static prop: Function, [name, Object], -> NILL
    @public @static computed: Function, [name, methods, collections, opts, lambda], -> NILL
    @public @static comp: Function, [name, methods, collections, opts, lambda], -> NILL
    @public @static belongsTo: Function, [name, schema, opts], -> NILL
    @public @static hasMany: Function, [name, opts], -> NILL
    @public @static hasOne: Function, [name, opts], -> NILL

    # @public @static validate: Function, [attribute, options], -> NILL

    @public @static new: Function, [attributes], -> ModelInterface

    # под вопросом ?????? возможно надо засунуть в сериалайзер
    @public @static serializableAttributes: Function, [], -> Object

    # @public _key: String
    # @public _rev: String
    # @public _type: String
    # @public isHidden: Boolean
    # @public createdAt: Date
    # @public updatedAt: Date
    # @public id: String
    # @public rev: String
    # @public type: String

    # под вопросом ??????
    @public validate: Function, [], -> SELF
    @public beforeValidate: Function, [], -> NILL
    @public afterValidate: Function, [], -> NILL
    @public save: Function, [], -> SELF
    @public beforeSave: Function, [], -> NILL
    @public afterSave: Function, [ANY], -> ANY # any type
    @public create: Function, [], -> SELF
    @public beforeCreate: Function, [], -> NILL
    @public afterCreate: Function, [ANY], -> ANY # any type
    @public update: Function, [], -> SELF
    @public beforeUpdate: Function, [], -> NILL
    @public afterUpdate: Function, [ANY], -> ANY # any type
    @public delete: Function, [], -> SELF
    @public beforeDelete: Function, [], -> NILL
    @public afterDelete: Function, [ANY], -> ANY # any type
    @public destroy: Function, [], -> SELF
    @public beforeDestroy: Function, [], -> NILL
    @public afterDestroy: Function, [], -> NILL
    @public recordHasBeenChanged: Function, [], -> NILL
    @public updateEdges: Function, [ANY], -> ANY # any type

    @public attributes: Function, [], -> Array

    # @public clone: Function, [], -> ModelInterface
    # @public copy: Function, [], -> ModelInterface
    # @public deepCopy: Function, [], -> ModelInterface
    # @public decrement: Function, [attribute, step], -> ModelInterface
    # @public increment: Function, [attribute, step], -> ModelInterface
    # @public toggle: Function, [attribute], -> ModelInterface
    # @public touch: Function, [], -> ModelInterface
    # @public updateAttribute: Function, [name, value], -> ModelInterface
    # @public updateAttributes: Function, [attributes], -> ModelInterface
    # @public isNew: Function, [], -> Boolean
    @private _resetAttributes: Function, [Object], -> ModelInterface
    # @public reload: Function, [], -> ModelInterface
    @public getSnapshot: Function, [], -> Object
    @private _forClient: Function, [Object], -> Object

    # под вопросом ?????? # возможно надо это определять в сериалайзере
    @public @static serializeFromBatch: Function, [Object], -> Object
    @public @static serializeFromClient: Function, [Object], -> Object
    @public serializeForClient: Function, [Object], -> Object






    @public @static @virtual inverseFor: Function,
      args: [String]
      return: Object # Cucumber.inverseFor 'tomato' #-> {type: App::Tomato, name: 'cucumbers', kind: 'hasMany'}

    @public @virtual _key: String
    @public @virtual _rev: String
    @public @virtual _type: String
    @public @virtual isHidden: Boolean
    @public @virtual createdAt: Date
    @public @virtual updatedAt: Date
    @public @virtual id: String
    @public @virtual rev: String
    @public @virtual type: String

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
