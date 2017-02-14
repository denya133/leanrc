{SELF, NILL, ANY} = FoxxMC::Constants

class CrudMixinInterface extends Interface
  @private record: [NILL, ANY]
  @private records: [NILL, Array]

  @public list: Function, [Object], -> Array
  @public detail: Function, [String], -> ANY
  @public create: Function, [Object], -> ANY
  @public update: Function, [String, Object], -> ANY
  @public delete: Function, [String], -> ANY

  @public beforeList: Function, [], -> NILL
  @public beforeDetail: Function, [], -> NILL
  @public beforeCreate: Function, [], -> NILL
  @public beforeUpdate: Function, [], -> NILL
  @public beforeDelete: Function, [], -> NILL
  @public afterList: Function, [ANY], -> ANY
  @public afterDetail: Function, [ANY], -> ANY
  @public afterCreate: Function, [ANY], -> ANY
  @public afterUpdate: Function, [ANY], -> ANY
  @public afterDelete: Function, [ANY], -> ANY

class ResourceInterface extends Interface
  @include CrudMixinInterface
  @private controller: ControllerInterface # setted by constructor()

class Resource extends CoreObject
  @implements ResourceInterface
