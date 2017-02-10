{SELF, NULL} = FoxxMC::Constants

class StoreInterface extends Interface
  @public adapter: String
  @public adapterFor: Function, [String], -> AdapterInterface
  @public createRecord: Function, [modelName, Object], -> ModelInterface
  @public deleteRecord: Function, [ModelInterface], -> NULL
  @public filter: Function, [modelName, query, filter], -> CursorInterface
  @public findAll: Function, [modelName, options], -> CursorInterface
  @public findRecord: Function, [modelName, id, options], -> ModelInterface
  @public getReference: Function, [type, id], -> InternalModelInterface
  @public hasRecordForId: Function, [modelName, id], -> Boolean # true if loaded
  @public modelFor: Function, [modelName], -> ModelClass
  @public normalize: Function, [modelName, payload], -> Object
  #This method returns a filtered array that contains all of the known records for a given type in the store.
  @public peekAll: Function, [modelName], -> Array
  # Get a record by a given type and ID without triggering a fetch.
  @public peekRecord: Function, [modelName, id], -> [ModelInterface, NULL]
  @public push: Function, [[Object, Array]], ->[ModelInterface, CursorInterface]
  @public pushPayload: Function, [modelName, inputPayload], -> NULL
  @public query: Function, [modelName, query], -> CursorInterface
  @public queryRecord: Function, [modelName, query], -> ModelInterface
  @public serializerFor: Function, [modelName], -> SerializerInterface
  @public unloadAll: Function, [modelName], -> NULL
  @public unloadRecord: Function, [ModelInterface], -> NULL

class Store extends Service
  @implements StoreInterface
