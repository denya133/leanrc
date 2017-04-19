

module.exports = (Module)->
  class MigrationInterface extends Module::Interface
    @inheritProtected()

    @Module: Module

    @public @async @virtual createCollection: Function,
      args: [String, Object]
      return: Module::ANY

    @public @static @virtual createCollection: Function,
      args: [String, Object]
      return: Module::NILL

    @public @async @virtual createEdgeCollection: Function,
      args: [String, String, Object]
      return: Module::ANY

    @public @static @virtual createEdgeCollection: Function,
      args: [String, String, Object]
      return: Module::NILL

    @public @async @virtual addField: Function,
      args: [String, String, Object]
      return: Module::ANY

    @public @static @virtual addField: Function,
      args: [String, String, Object]
      return: Module::NILL

    @public @async @virtual addIndex: Function,
      args: [String, Array, Object]
      return: Module::ANY

    @public @static @virtual addIndex: Function,
      args: [String, Array, Object]
      return: Module::NILL

    @public @async @virtual addTimestamps: Function,
      args: [String, Object]
      return: Module::ANY

    @public @static @virtual addTimestamps: Function,
      args: [String, Object]
      return: Module::NILL

    @public @async @virtual changeCollection: Function,
      args: [String, Object]
      return: Module::ANY

    @public @static @virtual changeCollection: Function,
      args: [String, Object]
      return: Module::NILL

    @public @async @virtual changeField: Function,
      args: [String, String, Object]
      return: Module::ANY

    @public @static @virtual changeField: Function,
      args: [String, String, Object]
      return: Module::NILL

    @public @async @virtual renameField: Function,
      args: [String, String, String]
      return: Module::ANY

    @public @static @virtual renameField: Function,
      args: [String, String, String]
      return: Module::NILL

    @public @async @virtual renameIndex: Function,
      args: [String, String, String]
      return: Module::ANY

    @public @static @virtual renameIndex: Function,
      args: [String, String, String]
      return: Module::NILL

    @public @async @virtual renameCollection: Function,
      args: [String, String, String]
      return: Module::ANY

    @public @static @virtual renameCollection: Function,
      args: [String, String, String]
      return: Module::NILL

    @public @async @virtual dropCollection: Function,
      args: [String]
      return: Module::ANY

    @public @static @virtual dropCollection: Function,
      args: [String]
      return: Module::NILL

    @public @async @virtual dropEdgeCollection: Function,
      args: [String, String]
      return: Module::ANY

    @public @static @virtual dropEdgeCollection: Function,
      args: [String, String]
      return: Module::NILL

    @public @async @virtual removeField: Function,
      args: [String, String]
      return: Module::ANY

    @public @static @virtual removeField: Function,
      args: [String, String]
      return: Module::NILL

    @public @async @virtual removeIndex: Function,
      args: [String, Array, Object]
      return: Module::ANY

    @public @static @virtual removeIndex: Function,
      args: [String, Array, Object]
      return: Module::NILL

    @public @async @virtual removeTimestamps: Function,
      args: [String, Object]
      return: Module::ANY

    @public @static @virtual removeTimestamps: Function,
      args: [String, Object]
      return: Module::NILL

    @public @static @virtual reversible: Function,
      args: [Function]
      return: Module::NILL

    @public @async @virtual execute: Function,
      args: [Function]
      return: Module::NILL

    @public @async @virtual migrate: Function,
      args: [Function]
      return: Module::NILL

    @public @static @virtual change: Function,
      args: [Function]
      return: Module::NILL

    @public @async @virtual up: Function,
      args: []
      return: Module::NILL

    @public @static @virtual up: Function,
      args: [Function]
      return: Module::NILL

    @public @async @virtual down: Function,
      args: []
      return: Module::NILL

    @public @static @virtual down: Function,
      args: [Function]
      return: Module::NILL


  MigrationInterface.initialize()
