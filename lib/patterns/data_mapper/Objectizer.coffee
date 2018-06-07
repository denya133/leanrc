# класс, который должен отвечать за деобжектизацию json-структуры в Record запись при получении из браузера например и за обжектизацию Record-объекта в json-структуру для отправки например в браузер.


module.exports = (Module)->
  class Objectizer extends Module::CoreObject
    @inheritProtected()
    # @implements Module::ObjectizerInterface
    @module Module

    @public collection: Module::CollectionInterface

    @public @async recoverize: Function,
      default: (acRecord, ahPayload)->
        ahPayload.type ?= "#{acRecord.moduleName()}::#{acRecord.name}"
        return yield acRecord.recoverize ahPayload, @collection

    @public @async objectize: Function,
      default: (aoRecord, options = null)->
        vcRecord = aoRecord.constructor
        yield return vcRecord.objectize aoRecord, options

    @public @static @async restoreObject: Function,
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          Facade = Module::ApplicationFacade ? Module::Facade
          facade = Facade.getInstance replica.multitonKey
          collection = facade.retrieveProxy replica.collectionName
          yield return collection.objectizer
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


  Objectizer.initialize()
