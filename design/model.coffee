{SELF, NULL, ANY} = FoxxMC::Constants

# Не декларировал методы которые находятся в Cursor и в Query потому что работа с квери будет вестись через стор (чтобы была единая точка в которой происходит создание всех объектов)

class ModelInterface extends Interface
  @public @static schema: JoiSchema
  @public @static customFilters: Function, [statement], -> NULL
  @private @static _customFilters: Function, [], -> Object
  @private @static _parentClassesNames: Function, [], -> Array
  @public @static collectionName: Function, [], -> String #adb
  @public @static collectionNameInDB: Function, [[String, NULL]], -> String #adb
  @public @static collectionPrefix: Function, [], -> String #adb
  @public @static getLocksFor: Function, [[String, Array], Array], ->Object #adb

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

  @public @static attribute: Function, [name, schema, Object], -> NULL
  @public @static attr: Function, [name, schema, Object], -> NULL
  @public @static property: Function, [name, Object], -> NULL
  @public @static prop: Function, [name, Object], -> NULL
  @public @static computed: Function, [name, methods, collections, opts, lambda], -> NULL
  @public @static comp: Function, [name, methods, collections, opts, lambda], -> NULL
  @public @static belongsTo: Function, [name, schema, opts], -> NULL
  @public @static hasMany: Function, [name, opts], -> NULL
  @public @static hasOne: Function, [name, opts], -> NULL

  @public @static validate: Function, [attribute, options], -> NULL

  @public @static new: Function, [attributes], -> ModelInterface

  @public @static serializableAttributes: Function, [], -> Object

  @public _key: String
  @public _rev: String
  @public _type: String
  @public isHidden: Boolean
  @public createdAt: Date
  @public updatedAt: Date
  @public id: String
  @public rev: String
  @public type: String

  @public validate: Function, [], -> SELF
  @public beforeValidate: Function, [], -> NULL
  @public afterValidate: Function, [], -> NULL
  @public save: Function, [], -> SELF
  @public beforeSave: Function, [], -> NULL
  @public afterSave: Function, [ANY], -> ANY # any type
  @public create: Function, [], -> SELF
  @public beforeCreate: Function, [], -> NULL
  @public afterCreate: Function, [ANY], -> ANY # any type
  @public update: Function, [], -> SELF
  @public beforeUpdate: Function, [], -> NULL
  @public afterUpdate: Function, [ANY], -> ANY # any type
  @public delete: Function, [], -> SELF
  @public beforeDelete: Function, [], -> NULL
  @public afterDelete: Function, [ANY], -> ANY # any type
  @public destroy: Function, [], -> SELF
  @public beforeDestroy: Function, [], -> NULL
  @public afterDestroy: Function, [], -> NULL
  @public recordHasBeenChanged: Function, [], -> NULL
  @public updateEdges: Function, [ANY], -> ANY # any type

  @public delay: Function, [Object], -> Object
  @public attributes: Function, [], -> Array
  @public clone: Function, [], -> ModelInterface
  @public copy: Function, [], -> ModelInterface
  @public deepCopy: Function, [], -> ModelInterface
  @public decrement: Function, [attribute, step], -> ModelInterface
  @public increment: Function, [attribute, step], -> ModelInterface
  @public toggle: Function, [attribute], -> ModelInterface
  @public touch: Function, [], -> ModelInterface
  @public updateAttribute: Function, [name, value], -> ModelInterface
  @public updateAttributes: Function, [attributes], -> ModelInterface
  @public isNew: Function, [], -> Boolean
  @private _resetAttributes: Function, [Object], -> ModelInterface
  @public reload: Function, [], -> ModelInterface
  @public getSnapshot: Function, [], -> Object
  @private _forClient: Function, [Object], -> Object

  @public @static serializeFromBatch: Function, [Object], -> Object
  @public @static serializeFromClient: Function, [Object], -> Object
  @public serializeForClient: Function, [Object], -> Object

class Model extends CoreObject
  @implements ModelInterface
