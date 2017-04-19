RC = require 'RC'
{ANY, NILL} = RC::


module.exports = (LeanRC)->
  class LeanRC::RelationsMixinInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

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


  return LeanRC::RelationsMixinInterface.initialize()
