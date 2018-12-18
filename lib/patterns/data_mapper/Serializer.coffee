# класс, который должен отвечать за сериализацию отдельной записи при сохранении ее через collection прокси в некоторое хранилище. т.е. за сериализацию отдельных атрибутов и их десериализацию при получении из хранилища.


module.exports = (Module)->
  {
    AnyT
    FuncG, SubsetG, MaybeG
    CollectionInterface, RecordInterface
    SerializerInterface
    CoreObject
  } = Module::

  class Serializer extends CoreObject
    @inheritProtected()
    @implements SerializerInterface
    @module Module

    @public collection: CollectionInterface

    @public @async normalize: FuncG([SubsetG(RecordInterface), MaybeG AnyT], RecordInterface),
      default: (acRecord, ahPayload)->
        return yield acRecord.normalize ahPayload, @collection

    @public @async serialize: FuncG([MaybeG(RecordInterface), MaybeG Object], MaybeG AnyT),
      default: (aoRecord, options = null)->
        vcRecord = aoRecord.constructor
        return yield vcRecord.serialize aoRecord, options

    @public @static @async restoreObject: FuncG([SubsetG(Module), Object], SerializerInterface),
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          Facade = Module::ApplicationFacade ? Module::Facade
          facade = Facade.getInstance replica.multitonKey
          collection = facade.retrieveProxy replica.collectionName
          yield return collection.serializer
        else
          return yield @super Module, replica

    @public @static @async replicateObject: FuncG(SerializerInterface, Object),
      default: (instance)->
        replica = yield @super instance
        ipsMultitonKey = Symbol.for '~multitonKey'
        replica.multitonKey = instance.collection[ipsMultitonKey]
        replica.collectionName = instance.collection.getProxyName()
        yield return replica

    @public init: FuncG(CollectionInterface),
      default: (args...)->
        @super args...
        [@collection] = args
        return


    @initialize()
