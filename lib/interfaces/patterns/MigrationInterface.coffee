

module.exports = (Module)->
  {
    AnyT, NilT, AsyncFunctionT
    FuncG, ListG, StructG, EnumG, MaybeG, UnionG, InterfaceG, AsyncFuncG
    RecordInterface
  } = Module::

  class MigrationInterface extends RecordInterface
    @inheritProtected()
    @module Module

    @const UP: UP = Symbol 'UP'
    @const DOWN: DOWN = Symbol 'DOWN'
    @const SUPPORTED_TYPES: SUPPORTED_TYPES = {
      json:         'json'
      binary:       'binary'
      boolean:      'boolean'
      date:         'date'
      datetime:     'datetime'
      decimal:      'decimal'
      float:        'float'
      integer:      'integer'
      primary_key:  'primary_key'
      string:       'string'
      text:         'text'
      time:         'time'
      timestamp:    'timestamp'
      array:        'array'
      hash:         'hash'
    }

    @virtual steps: ListG StructG {
      args: Array
      method: EnumG [
        'createCollection'
        'createEdgeCollection'
        'addField'
        'addIndex'
        'addTimestamps'
        'changeCollection'
        'changeField'
        'renameField'
        'renameIndex'
        'renameCollection'
        'dropCollection'
        'dropEdgeCollection'
        'removeField'
        'removeIndex'
        'removeTimestamps'
        'reversible'
      ]
    }

    @virtual @static createCollection: FuncG [String, MaybeG Object], NilT

    @virtual @async createCollection: FuncG [String, MaybeG Object], NilT

    @virtual @static createEdgeCollection: FuncG [String, String, MaybeG Object], NilT

    @virtual @async createEdgeCollection: FuncG [String, String, MaybeG Object], NilT

    @virtual @static addField: FuncG [String, String, UnionG(
      EnumG SUPPORTED_TYPES
      InterfaceG {
        type: EnumG SUPPORTED_TYPES
        default: AnyT
      }
    )], NilT

    @virtual @async addField: FuncG [String, String, UnionG(
      EnumG SUPPORTED_TYPES
      InterfaceG {
        type: EnumG SUPPORTED_TYPES
        default: AnyT
      }
    )], NilT

    @virtual @static addIndex: FuncG [String, ListG(String), InterfaceG {
      type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
      unique: MaybeG Boolean
      sparse: MaybeG Boolean
    }], NilT

    @virtual @async addIndex: FuncG [String, ListG(String), InterfaceG {
      type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
      unique: MaybeG Boolean
      sparse: MaybeG Boolean
    }], NilT

    @virtual @static addTimestamps: FuncG [String, MaybeG Object], NilT

    @virtual @async addTimestamps: FuncG [String, MaybeG Object], NilT

    @virtual @static changeCollection: FuncG [String, Object], NilT

    @virtual @async changeCollection: FuncG [String, Object], NilT

    @virtual @static changeField: FuncG [String, String, UnionG(
      EnumG SUPPORTED_TYPES
      InterfaceG {
        type: EnumG SUPPORTED_TYPES
      }
    )], NilT

    @virtual @async changeField: FuncG [String, String, UnionG(
      EnumG SUPPORTED_TYPES
      InterfaceG {
        type: EnumG SUPPORTED_TYPES
      }
    )], NilT

    @virtual @static renameField: FuncG [String, String, String], NilT

    @virtual @async renameField: FuncG [String, String, String], NilT

    @virtual @static renameIndex: FuncG [String, String, String], NilT

    @virtual @async renameIndex: FuncG [String, String, String], NilT

    @virtual @static renameCollection: FuncG [String, String], NilT

    @virtual @async renameCollection: FuncG [String, String], NilT

    @virtual @static dropCollection: FuncG String, NilT

    @virtual @async dropCollection: FuncG String, NilT

    @virtual @static dropEdgeCollection: FuncG [String, String], NilT

    @virtual @async dropEdgeCollection: FuncG [String, String], NilT

    @virtual @static removeField: FuncG [String, String], NilT

    @virtual @async removeField: FuncG [String, String], NilT

    @virtual @static removeIndex: FuncG [String, ListG(String), InterfaceG {
      type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
      unique: MaybeG Boolean
      sparse: MaybeG Boolean
    }], NilT

    @virtual @async removeIndex: FuncG [String, ListG(String), InterfaceG {
      type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
      unique: MaybeG Boolean
      sparse: MaybeG Boolean
    }], NilT

    @virtual @static removeTimestamps: FuncG [String, MaybeG Object], NilT

    @virtual @async removeTimestamps: FuncG [String, MaybeG Object], NilT

    @virtual @static reversible: FuncG AsyncFuncG(
      StructG {
        up: AsyncFuncG AsyncFunctionT, NilT
        down: AsyncFuncG AsyncFunctionT, NilT
      }
      NilT
    ), NilT

    @virtual @async execute: FuncG AsyncFunctionT, NilT

    @virtual @async migrate: FuncG [EnumG UP, DOWN], NilT

    @virtual @static change: FuncG Function, NilT

    @virtual @async up: Function

    @virtual @static up: FuncG AsyncFunctionT, NilT

    @virtual @async down: Function

    @virtual @static down: FuncG AsyncFunctionT, NilT


    @initialize()
