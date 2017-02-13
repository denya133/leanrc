{SELF, NULL, ANY} = FoxxMC::Constants

class CrudMixinInterface extends Interface
  @private record: [NULL, ANY]
  @private records: [NULL, Array]

  @public list: Function, [Object], -> Array
  @public detail: Function, [String], -> ANY
  @public create: Function, [Object], -> ANY
  @public update: Function, [String, Object], -> ANY
  @public delete: Function, [String], -> ANY

  @public beforeList: Function, [], -> NULL
  @public beforeDetail: Function, [], -> NULL
  @public beforeCreate: Function, [], -> NULL
  @public beforeUpdate: Function, [], -> NULL
  @public beforeDelete: Function, [], -> NULL
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
