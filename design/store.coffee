{SELF, NILL, ANY} = FoxxMC::Constants

class StoreInterface extends Interface
  @public defaultAdapter: String # adapter type by default ['-arangodb', '-mongodb', '-rest', '-json-api']
  @public adapterFor: Function, [modelName], -> AdapterInterface
  @public serializerFor: Function, [modelName], -> SerializerInterface
  @public modelFor: Function, [modelName], -> ModelClass

  @public create: Function, [modelName, Object], -> ModelInterface
  @public createDirectly: Function, [modelName, Object], -> ModelInterface
  @public delete: Function, [modelName, String], -> ModelInterface
  @public deleteBy: Function, [modelName, QueryObjectInterface], -> ModelInterface
  @public destroy: Function, [modelName, String], -> NILL
  @public destroyBy: Function, [modelName, QueryObjectInterface], -> NILL
  @public find: Function, [modelName, String], -> ModelInterface
  @public findBy: Function, [modelName, QueryObjectInterface], -> ModelInterface
  @public filter: Function, [modelName, QueryObjectInterface], -> CursorInterface
  @public update: Function, [modelName, String, Object], -> ModelInterface
  @public updateBy: Function, [modelName, QueryObjectInterface, Object], -> ModelInterface
  @public query: Function, [modelName, QueryObjectInterface], -> ANY
  @public forEach: Function, [modelName, Function], -> NILL
  @public map: Function, [modelName, Function], -> CursorInterface
  @public reduce: Function, [modelName, Function, ANY], -> ANY
  @public sortBy: Function, [modelName, Object], -> CursorInterface
  @public groupBy: Function, [modelName, Object], -> ANY
  @public includes: Function, [modelName, String], -> Boolean
  @public exists: Function, [modelName, QueryObjectInterface], -> Boolean
  @public length: Function, [modelName], -> Number
  @public pushInto: Function, [modelName, [Array, Object]], -> Boolean
  @public push: Function, [Object], -> Boolean # when keys are modelNames

  @public getInternalModel: Function, [type, id], -> InternalModelInterface

  # normalize converts a json payload into the normalized form that push expects.
  @public normalize: Function, [modelName, Object], -> Object # eq. serializeFromClient
  @public serialize: Function, [modelName, String], -> Object # eq. serializeForClient

class Store extends Service
  @implements StoreInterface
