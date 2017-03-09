# здесь надо объявить интерфейсные методы. property, belongsTo, hasMany и hasOne
# этот интерфейс будет имплементиться в платформозависимых миксинах например ArangoRelationsMixin, которые будут инклудиться только в тех унаследованных от рекорда классах, где решейшены объявляются по факту необходимости.

RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::RelationsMixinInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @static @virtual properties: Function,
      args: []
      return: Object
    @public @static @virtual property: Function,
      args: [String, Object] #name, Object
      return: RC::Constants.NILL
    @public @static @virtual prop: Function,
      args: [String, Object] #name, Object
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
    @public @static @virtual inverseFor: Function,
      args: [String]
      return: Object # Cucumber.inverseFor 'tomato' #-> {type: App::Tomato, name: 'cucumbers', kind: 'hasMany'}


  return LeanRC::RelationsMixinInterface.initialize()
