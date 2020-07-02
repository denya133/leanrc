# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

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
