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

# класс, который должен отвечать за деобжектизацию json-структуры в Record запись при получении из браузера например и за обжектизацию Record-объекта в json-структуру для отправки например в браузер.

module.exports = (Module)->
  {
    AnyT
    FuncG, SubsetG, MaybeG
    CollectionInterface, RecordInterface
    ObjectizerInterface
    CoreObject
  } = Module::

  class Objectizer extends CoreObject
    @inheritProtected()
    @implements ObjectizerInterface
    @module Module

    @public collection: CollectionInterface

    @public @async recoverize: FuncG([SubsetG(RecordInterface), MaybeG Object], MaybeG RecordInterface),
      default: (acRecord, ahPayload)->
        ahPayload.type ?= "#{acRecord.moduleName()}::#{acRecord.name}"
        return yield acRecord.recoverize ahPayload, @collection

    @public @async objectize: FuncG([MaybeG(RecordInterface), MaybeG Object], MaybeG Object),
      default: (aoRecord, options = null)->
        vcRecord = aoRecord.constructor
        yield return vcRecord.objectize aoRecord, options

    @public @static @async restoreObject: FuncG([SubsetG(Module), Object], ObjectizerInterface),
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          Facade = Module::ApplicationFacade ? Module::Facade
          facade = Facade.getInstance replica.multitonKey
          collection = facade.retrieveProxy replica.collectionName
          yield return collection.objectizer
        else
          return yield @super Module, replica

    @public @static @async replicateObject: FuncG(ObjectizerInterface, Object),
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
