{SELF, NULL, JoiSchema} = FoxxMC::Constants

# получение каких либо данных или вызовы методов, которые должны изменять какие либо данные должны быть адресованы к @[ipoResource] - через указатель, т.к. это private проперти

class FoxxMC::ControllerInterface extends FoxxMC::Interface
  @private resource: ResourceInterface # setted by constructor()
  @private query: Object
  @private body: Object
  @private recordId: String
  @private patchData: Object
  @private currentUser: Object

  @public @static swaggerDefinition: Function, [action, lambda], -> NULL
  @public @static keyName: Function, [], -> String
  @public @static keySchema: JoiSchema
  @public @static querySchema: JoiSchema
  @public @static schema: JoiSchema
  @public @static clientSchema: JoiSchema
  @public @static clientSchemaForArray: JoiSchema
  @public @static itemForClient: Object
  @public @static itemsForClient: Object
  @public @static actions: Function, [], -> Array
  @public @static action: Function, [name, lambda], -> NULL

  @public itemDecorator: Function, [item], -> Object
  @public itemsDecorator: Function, [items], -> Array
  @public deleteDecorator: Function, [item], -> NULL
  @public listDecorator: Function, [Object], -> Array
  @public initializeDependencies: Function, [], -> NULL
  @public checkApiVersion: Function, [], -> NULL
  @public permitBody: Function, [], -> NULL
  @public setOwnerId: Function, [], -> NULL
  @public protectOwnerId: Function, [], -> NULL
  @public protectSpaceId: Function, [], -> NULL
  @public beforeList: Function, [], -> NULL
  @public beforeLimitedList: Function, [], -> NULL
  @public beforeDetail: Function, [], -> NULL
  @public beforeCreate: Function, [], -> NULL
  @public beforeUpdate: Function, [], -> NULL
  @public beforeDelete: Function, [], -> NULL
  @public afterCreate: Function, [], -> NULL
  @public afterUpdate: Function, [], -> NULL
  @public afterDelete: Function, [], -> NULL
  @public _checkHeader: Function, [req], -> Boolean
  @public checkSession: Function, [], -> NULL
  @public checkOwner: Function, [], -> NULL
  @public adminOnly: Function, [], -> NULL

  @public list: Function, [], -> NULL
  @public detail: Function, [], -> NULL
  @public create: Function, [], -> NULL
  @public update: Function, [], -> NULL
  @public delete: Function, [], -> NULL

  @public _swaggerDefFor_list: Function, [endpoint], -> NULL
  @public _swaggerDefFor_detail: Function, [endpoint], -> NULL
  @public _swaggerDefFor_create: Function, [endpoint], -> NULL
  @public _swaggerDefFor_update: Function, [endpoint], -> NULL
  @public _swaggerDefFor_delete: Function, [endpoint], -> NULL

class FoxxMC::Controller extends FoxxMC::CoreObject
  @implements FoxxMC::ControllerInterface
