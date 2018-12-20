

module.exports = (Module)->
  {
    AnyT, AsyncFunctionT
    FuncG, ListG, StructG, EnumG, MaybeG, UnionG, InterfaceG, AsyncFuncG
    Interface
  } = Module::

  class MigrationInterface extends Interface
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
      number:       'number'
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

    @virtual @static createCollection: FuncG [String, MaybeG Object]

    @virtual @async createCollection: FuncG [String, MaybeG Object]

    @virtual @static createEdgeCollection: FuncG [String, String, MaybeG Object]

    @virtual @async createEdgeCollection: FuncG [String, String, MaybeG Object]

    @virtual @static addField: FuncG [String, String, UnionG(
      EnumG SUPPORTED_TYPES
      InterfaceG {
        type: EnumG SUPPORTED_TYPES
        default: AnyT
      }
    )]

    @virtual @async addField: FuncG [String, String, UnionG(
      EnumG SUPPORTED_TYPES
      InterfaceG {
        type: EnumG SUPPORTED_TYPES
        default: AnyT
      }
    )]

    @virtual @static addIndex: FuncG [String, ListG(String), InterfaceG {
      type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
      unique: MaybeG Boolean
      sparse: MaybeG Boolean
    }]

    @virtual @async addIndex: FuncG [String, ListG(String), InterfaceG {
      type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
      unique: MaybeG Boolean
      sparse: MaybeG Boolean
    }]

    @virtual @static addTimestamps: FuncG [String, MaybeG Object]

    @virtual @async addTimestamps: FuncG [String, MaybeG Object]

    @virtual @static changeCollection: FuncG [String, Object]

    @virtual @async changeCollection: FuncG [String, Object]

    @virtual @static changeField: FuncG [String, String, UnionG(
      EnumG SUPPORTED_TYPES
      InterfaceG {
        type: EnumG SUPPORTED_TYPES
      }
    )]

    @virtual @async changeField: FuncG [String, String, UnionG(
      EnumG SUPPORTED_TYPES
      InterfaceG {
        type: EnumG SUPPORTED_TYPES
      }
    )]

    @virtual @static renameField: FuncG [String, String, String]

    @virtual @async renameField: FuncG [String, String, String]

    @virtual @static renameIndex: FuncG [String, String, String]

    @virtual @async renameIndex: FuncG [String, String, String]

    @virtual @static renameCollection: FuncG [String, String]

    @virtual @async renameCollection: FuncG [String, String]

    @virtual @static dropCollection: FuncG String

    @virtual @async dropCollection: FuncG String

    @virtual @static dropEdgeCollection: FuncG [String, String]

    @virtual @async dropEdgeCollection: FuncG [String, String]

    @virtual @static removeField: FuncG [String, String]

    @virtual @async removeField: FuncG [String, String]

    @virtual @static removeIndex: FuncG [String, ListG(String), InterfaceG {
      type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
      unique: MaybeG Boolean
      sparse: MaybeG Boolean
    }]

    @virtual @async removeIndex: FuncG [String, ListG(String), InterfaceG {
      type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
      unique: MaybeG Boolean
      sparse: MaybeG Boolean
    }]

    @virtual @static removeTimestamps: FuncG [String, MaybeG Object]

    @virtual @async removeTimestamps: FuncG [String, MaybeG Object]

    @virtual @static reversible: FuncG AsyncFuncG(
      StructG {
        up: AsyncFuncG AsyncFunctionT
        down: AsyncFuncG AsyncFunctionT
      }
    )

    @virtual @async execute: FuncG AsyncFunctionT

    @virtual @async migrate: FuncG [EnumG UP, DOWN]

    @virtual @static change: FuncG Function

    @virtual @async up: Function

    @virtual @static up: FuncG AsyncFunctionT

    @virtual @async down: Function

    @virtual @static down: FuncG AsyncFunctionT


    @initialize()
