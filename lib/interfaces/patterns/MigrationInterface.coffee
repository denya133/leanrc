

module.exports = (Module)->
  {NILL} = Module::

  class MigrationInterface extends Module::Interface
    @inheritProtected()

    @module Module

    @public @async @virtual createCollection: Function,
      args: [String, Object]
      return: NILL

    @public @static @virtual createCollection: Function,
      args: [String, Object]
      return: NILL

    @public @async @virtual createEdgeCollection: Function,
      args: [String, String, Object]
      return: NILL

    @public @static @virtual createEdgeCollection: Function,
      args: [String, String, Object]
      return: NILL

    @public @async @virtual addField: Function,
      args: [String, String, Object]
      return: NILL

    @public @static @virtual addField: Function,
      args: [String, String, Object]
      return: NILL

    @public @async @virtual addIndex: Function,
      args: [String, Array, Object]
      return: NILL

    @public @static @virtual addIndex: Function,
      args: [String, Array, Object]
      return: NILL

    @public @async @virtual addTimestamps: Function,
      args: [String, Object]
      return: NILL

    @public @static @virtual addTimestamps: Function,
      args: [String, Object]
      return: NILL

    @public @async @virtual changeCollection: Function,
      args: [String, Object]
      return: NILL

    @public @static @virtual changeCollection: Function,
      args: [String, Object]
      return: NILL

    @public @async @virtual changeField: Function,
      args: [String, String, Object]
      return: NILL

    @public @static @virtual changeField: Function,
      args: [String, String, Object]
      return: NILL

    @public @async @virtual renameField: Function,
      args: [String, String, String]
      return: NILL

    @public @static @virtual renameField: Function,
      args: [String, String, String]
      return: NILL

    @public @async @virtual renameIndex: Function,
      args: [String, String, String]
      return: NILL

    @public @static @virtual renameIndex: Function,
      args: [String, String, String]
      return: NILL

    @public @async @virtual renameCollection: Function,
      args: [String, String, String]
      return: NILL

    @public @static @virtual renameCollection: Function,
      args: [String, String, String]
      return: NILL

    @public @async @virtual dropCollection: Function,
      args: [String]
      return: NILL

    @public @static @virtual dropCollection: Function,
      args: [String]
      return: NILL

    @public @async @virtual dropEdgeCollection: Function,
      args: [String, String]
      return: NILL

    @public @static @virtual dropEdgeCollection: Function,
      args: [String, String]
      return: NILL

    @public @async @virtual removeField: Function,
      args: [String, String]
      return: NILL

    @public @static @virtual removeField: Function,
      args: [String, String]
      return: NILL

    @public @async @virtual removeIndex: Function,
      args: [String, Array, Object]
      return: NILL

    @public @static @virtual removeIndex: Function,
      args: [String, Array, Object]
      return: NILL

    @public @async @virtual removeTimestamps: Function,
      args: [String, Object]
      return: NILL

    @public @static @virtual removeTimestamps: Function,
      args: [String, Object]
      return: NILL

    @public @static @virtual reversible: Function,
      args: [Function]
      return: NILL

    @public @async @virtual execute: Function,
      args: [Function]
      return: NILL

    @public @async @virtual migrate: Function,
      args: [Function]
      return: NILL

    @public @static @virtual change: Function,
      args: [Function]
      return: NILL

    @public @async @virtual up: Function,
      args: []
      return: NILL

    @public @static @virtual up: Function,
      args: [Function]
      return: NILL

    @public @async @virtual down: Function,
      args: []
      return: NILL

    @public @static @virtual down: Function,
      args: [Function]
      return: NILL


  MigrationInterface.initialize()
