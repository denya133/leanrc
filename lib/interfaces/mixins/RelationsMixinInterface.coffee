

module.exports = (Module)->
  {ANY, NILL} = Module::

  class RelationsMixinInterface extends Module::Interface
    @inheritProtected()

    @module Module

    @public @static @virtual relations: Function,
      args: []
      return: Object
    @public @static @virtual belongsTo: Function,
      args: [String, Object, Object] # name, schema, opts
      return: NILL
    @public @static @virtual hasMany: Function,
      args: [String, Object] #name, opts
      return: NILL
    @public @static @virtual hasOne: Function,
      args: [String, Object] #name, opts
      return: NILL
    @public @static @virtual inverseFor: Function,
      args: [String]
      return: Object


  RelationsMixinInterface.initialize()
