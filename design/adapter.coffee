{SELF, NILL, ANY} = FoxxMC::Constants

class AdapterInterface extends Interface
  @public defaultSerializer: String # ['-arangodb', '-mongodb', '-rest', '-json-api']
  @public generateIdForRecord: Function, [], -> [String, NILL]

  @public @virtual insertRecord: Function, [store, type, snapshot], -> Object
  @public @virtual destroyRecord: Function, [store, type, snapshot], -> NILL
  @public @virtual updateRecord: Function, [store, type, snapshot], -> Object
  @public @virtual findRecord: Function, [store, type, query], -> Object
  @public @virtual insertMany: Function, [store, type, snapshots], -> CursorInterface
  @public @virtual destroyMany: Function, [store, type, query], -> NILL
  @public @virtual updateMany: Function, [store, type, query, data], -> CursorInterface
  @public @virtual findMany: Function, [store, type, query], -> CursorInterface

  @public @virtual query:        Function, [store, type, query], -> ANY
  @public @virtual copy:         Function, [store, type, snapshot], -> Object
  @public @virtual deepCopy:     Function, [store, type, snapshot], -> Object
  @public @virtual map:          Function, [store, type, Function], -> CursorInterface
  @public @virtual forEach:      Function, [store, type, Function], -> NILL
  @public @virtual reduce:       Function, [store, type, Function, initial], -> ANY

  # proxies serializer work
  @public serialize:    Function, [snapshot, options], -> data

class Adapter extends CoreObject
  @implements AdapterInterface


# example in use
###
```coffee
  class Test::ApplicationAdapter extends ArangodbAdapter
    @Module: Test
  module.exports = Test::ApplicationAdapter.initialize()
```
###
