{SELF, NILL, ANY} = FoxxMC::Constants

class SnapshotInterface extends Interface
  @public id: String
  @public adapterOptions: Object
  @public modelName: String
  @public record: ModelInterface
  @public type: ModelClass

  @public attr: Function, [String], -> ANY
  @public attributes: Function, [], -> Object
  @public belongsTo: Function, [keyName, options], -> [SnapshotInterface, String, NILL]
  @public changedAttributesObject: Function, [], -> Object
  @public eachAttribute: Function, [lambda, binding], -> NILL
  @public eachRelationship: Function, [lambda, binding], -> NILL
  @public hasMany: Function, [keyName, options], -> [Array, NILL]
  @public serialize: Function, [options], -> Object

class Snapshot extends CoreObject
  @implements SnapshotInterface
