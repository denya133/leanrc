{SELF, NILL, ANY} = FoxxMC::Constants

class AdapterInterface extends Interface
  @public defaultSerializer: String # ['-arangodb', '-mongodb', '-rest', '-json-api']
  @public generateIdForRecord: Function, [], -> [String, NILL]

  @public insertRecord: Function, [store, type, snapshot], -> Object
  @public destroyRecord: Function, [store, type, snapshot], -> NILL
  @public updateRecord: Function, [store, type, snapshot], -> Object
  @public findRecord: Function, [store, type, query], -> Object
  @public insertMany: Function, [store, type, snapshots], -> CursorInterface
  @public destroyMany: Function, [store, type, query], -> NILL
  @public updateMany: Function, [store, type, query, data], -> CursorInterface
  @public findMany: Function, [store, type, query], -> CursorInterface

  @public query:        Function, [store, type, query], -> ANY
  @public copy:         Function, [store, type, snapshot], -> Object
  @public deepCopy:     Function, [store, type, snapshot], -> Object
  @public map:          Function, [store, type, Function], -> CursorInterface
  @public forEach:      Function, [store, type, Function], -> NILL
  @public reduce:       Function, [store, type, Function, initial], -> ANY

  # proxies serializer work
  @public serialize:    Function, [snapshot, options], -> data

class Adapter extends CoreObject
  @implements AdapterInterface
