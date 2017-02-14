{SELF, NILL, JoiSchema} = FoxxMC::Constants

# получение каких либо данных или вызовы методов, которые должны изменять какие либо данные должны быть адресованы к @[ipoResource] - через указатель, т.к. это private проперти

class FoxxMC::ControllerInterface extends FoxxMC::Interface
  @private resource: ResourceInterface # setted by constructor()
  @private query: Object
  @private body: Object
  @private recordId: String
  @private patchData: Object
  @private currentUser: Object

  @public @static swaggerDefinition: Function, [action, lambda], -> NILL
  @public @static keyName: Function, [], -> String
  @public @static keySchema: JoiSchema
  @public @static querySchema: JoiSchema
  @public @static schema: JoiSchema
  @public @static clientSchema: JoiSchema
  @public @static clientSchemaForArray: JoiSchema
  @public @static itemForClient: Object
  @public @static itemsForClient: Object
  @public @static actions: Function, [], -> Array
  @public @static action: Function, [name, lambda], -> NILL

  @public itemDecorator: Function, [item], -> Object
  @public itemsDecorator: Function, [items], -> Array
  @public deleteDecorator: Function, [item], -> NILL
  @public listDecorator: Function, [Object], -> Array
  @public initializeDependencies: Function, [], -> NILL
  @public checkApiVersion: Function, [], -> NILL
  @public permitBody: Function, [], -> NILL
  @public setOwnerId: Function, [], -> NILL
  @public protectOwnerId: Function, [], -> NILL
  @public protectSpaceId: Function, [], -> NILL
  @public beforeList: Function, [], -> NILL
  @public beforeLimitedList: Function, [], -> NILL
  @public beforeDetail: Function, [], -> NILL
  @public beforeCreate: Function, [], -> NILL
  @public beforeUpdate: Function, [], -> NILL
  @public beforeDelete: Function, [], -> NILL
  @public afterCreate: Function, [], -> NILL
  @public afterUpdate: Function, [], -> NILL
  @public afterDelete: Function, [], -> NILL
  @public _checkHeader: Function, [req], -> Boolean
  @public checkSession: Function, [], -> NILL
  @public checkOwner: Function, [], -> NILL
  @public adminOnly: Function, [], -> NILL

  @public list: Function, [], -> NILL
  @public detail: Function, [], -> NILL
  @public create: Function, [], -> NILL
  @public update: Function, [], -> NILL
  @public delete: Function, [], -> NILL

  @public _swaggerDefFor_list: Function, [endpoint], -> NILL
  @public _swaggerDefFor_detail: Function, [endpoint], -> NILL
  @public _swaggerDefFor_create: Function, [endpoint], -> NILL
  @public _swaggerDefFor_update: Function, [endpoint], -> NILL
  @public _swaggerDefFor_delete: Function, [endpoint], -> NILL

class FoxxMC::Controller extends FoxxMC::CoreObject
  @implements FoxxMC::ControllerInterface
