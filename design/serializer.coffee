{SELF, NILL, ANY} = FoxxMC::Constants

class SerializerInterface extends Interface
  @public store: StoreInterface

  @public normalize: Function, [typeClass, hash], -> Object
  @public normalizeResponse: Function, [store, primaryModelClass, payload, id, requestType], -> Object
  @public serialize: Function, [snapshot, options], -> Object

class Serializer extends CoreObject
  @implements SerializerInterface


# example in use
###
```coffee
  class Test::ApplicationSerializer extends ArangodbSerializer
    @Module: Test
  module.exports = Test::ApplicationSerializer.initialize()
```
###
