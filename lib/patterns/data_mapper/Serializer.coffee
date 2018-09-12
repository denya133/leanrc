# класс, который должен отвечать за сериализацию отдельной записи при сохранении ее через collection прокси в некоторое хранилище. т.е. за сериализацию отдельных атрибутов и их десериализацию при получении из хранилища.


module.exports = (Module)->
  class Serializer extends Module::CoreObject
    @inheritProtected()
    # @implements Module::SerializerInterface
    @module Module

    @public collection: Module::CollectionInterface

    @public @async normalize: Function,
      default: (acRecord, ahPayload)->
        return yield acRecord.normalize ahPayload, @collection

    @public @async serialize: Function,
      default: (aoRecord, options = null)->
        vcRecord = aoRecord.constructor
        return yield vcRecord.serialize aoRecord, options

    @public @static @async restoreObject: Function,
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          Facade = Module::ApplicationFacade ? Module::Facade
          facade = Facade.getInstance replica.multitonKey
          collection = facade.retrieveProxy replica.collectionName
          yield return collection.serializer
        else
          return yield @super Module, replica

    @public @static @async replicateObject: Function,
      default: (instance)->
        replica = yield @super instance
        ipsMultitonKey = Symbol.for '~multitonKey'
        replica.multitonKey = instance.collection[ipsMultitonKey]
        replica.collectionName = instance.collection.getProxyName()
        yield return replica

    @public init: Function,
      default: (args...)->
        @super args...
        [@collection] = args
        @


    @initialize()
