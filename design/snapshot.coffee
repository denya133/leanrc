{SELF, NULL, ANY} = FoxxMC::Constants

class SnapshotInterface extends Interface
  @public id: String
  @public adapterOptions: Object
  @public modelName: String
  @public record: ModelInterface
  @public type: ModelClass

  @public attr: Function, [String], -> ANY
  @public attributes: Function, [], -> Object
  @public belongsTo: Function, [keyName, options], -> [SnapshotInterface, String, NULL]
  @public changedAttributesObject: Function, [], -> Object
  @public eachAttribute: Function, [lambda, binding], -> NULL
  @public eachRelationship: Function, [lambda, binding], -> NULL
  @public hasMany: Function, [keyName, options], -> [Array, NULL]
  @public serialize: Function, [options], -> Object

class Snapshot extends Service
  @implements SnapshotInterface
