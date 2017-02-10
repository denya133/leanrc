{SELF, NULL, ANY} = FoxxMC::Constants

class SerializerInterface extends Interface
  @public store: StoreInterface

  @public normalize: Function, [typeClass, hash], -> Object
  @public normalizeResponse: Function, [store, primaryModelClass, payload, id, requestType], -> Object
  @public serialize: Function, [snapshot, options], -> Object

class Serializer extends Service
  @implements SerializerInterface
