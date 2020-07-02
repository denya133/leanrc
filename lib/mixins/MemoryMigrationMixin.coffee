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

module.exports = (Module)->
  {
    AnyT, AsyncFunctionT
    FuncG, ListG, EnumG, MaybeG, UnionG, InterfaceG
    Migration
    Mixin
    Utils: { _, inflect }
  } = Module::

  Module.defineMixin Mixin 'MemoryMigrationMixin', (BaseClass = Migration) ->
    class extends BaseClass
      @inheritProtected()

      { UP, DOWN, SUPPORTED_TYPES } = @::

      @public @async createCollection: FuncG([String, MaybeG Object]),
        default: (name, options)-> yield return

      @public @async createEdgeCollection: FuncG([String, String, MaybeG Object]),
        default: (collection_1, collection_2, options)-> yield return

      @public @async addField: FuncG([String, String, UnionG(
        EnumG SUPPORTED_TYPES
        InterfaceG {
          type: EnumG SUPPORTED_TYPES
          default: AnyT
        }
      )]),
        default: (collection_name, field_name, options)->
          if _.isString options
            yield return
          collectionName = "#{inflect.camelize collection_name}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          if options.default?
            if _.isNumber(options.default) or _.isBoolean(options.default)
              initial = options.default
            else if _.isDate options.default
              initial = options.default.toISOString()
            else if _.isString options.default
              initial = "#{options.default}"
            else
              initial = null
          else
            initial = null
          for own id, doc of memCollection[ipoCollection]
            doc[field_name] ?= initial
          yield return

      @public @async addIndex: FuncG([String, ListG(String), InterfaceG {
        type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
        unique: MaybeG Boolean
        sparse: MaybeG Boolean
      }]),
        default: (collection_name, field_names, options)-> yield return

      @public @async addTimestamps: FuncG([String, MaybeG Object]),
        default: (collection_name, options = {})->
          collectionName = "#{inflect.camelize collection_name}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          for own id, doc of memCollection[ipoCollection]
            doc.createdAt ?= null
            doc.updatedAt ?= null
            doc.deletedAt ?= null
          yield return

      @public @async changeCollection: FuncG([String, Object]),
        default: (name, options)-> yield return

      @public @async changeField: FuncG([String, String, UnionG(
        EnumG SUPPORTED_TYPES
        InterfaceG {
          type: EnumG SUPPORTED_TYPES
        }
      )]),
        default: (collection_name, field_name, options = {})->
          {
            json
            binary
            boolean
            date
            datetime
            number
            decimal
            float
            integer
            primary_key
            string
            text
            time
            timestamp
            array
            hash
          } = Module::Migration::SUPPORTED_TYPES
          collectionName = "#{inflect.camelize collection_name}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          type = if _.isString options
            options
          else
            options.type
          for own id, doc of memCollection[ipoCollection]
            switch type
              when boolean
                doc[field_name] = Boolean doc[field_name]
              when decimal, float, integer, number
                doc[field_name] = Number doc[field_name]
              when string, text, primary_key, binary
                doc[field_name] = String JSON.stringify doc[field_name]
              when json, hash, array
                doc[field_name] = JSON.parse String doc[field_name]
              when date, datetime
                doc[field_name] = new Date(String  doc[field_name]).toISOString()
              when time, timestamp
                doc[field_name] = new Date(String  doc[field_name]).getTime()
          yield return

      @public @async renameField: FuncG([String, String, String]),
        default: (collection_name, field_name, new_field_name)->
          collectionName = "#{inflect.camelize collection_name}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          for own id, doc of memCollection[ipoCollection]
            doc[new_field_name] = doc[field_name]
            delete doc[field_name]
          yield return

      @public @async renameIndex: FuncG([String, String, String]),
        default: (collection_name, old_name, new_name)-> yield return

      @public @async renameCollection: FuncG([String, String]),
        default: (collection_name, new_name)-> yield return

      @public @async dropCollection: FuncG(String),
        default: (collection_name)->
          collectionName = "#{inflect.camelize collection_name}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          for own id, doc of @collection[ipoCollection]
            delete memCollection[ipoCollection][id]
          memCollection[ipoCollection] = {}
          yield return

      @public @async dropEdgeCollection: FuncG([String, String]),
        default: (collection_1, collection_2)->
          qualifiedName = "#{collection_1}_#{collection_2}"
          collectionName = "#{inflect.camelize qualifiedName}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          for own id, doc of @collection[ipoCollection]
            delete memCollection[ipoCollection][id]
          memCollection[ipoCollection] = {}
          yield return

      @public @async removeField: FuncG([String, String]),
        default: (collection_name, field_name)->
          collectionName = "#{inflect.camelize collection_name}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          for own id, doc of memCollection[ipoCollection]
            delete doc[field_name]
          yield return

      @public @async removeIndex: FuncG([String, ListG(String), InterfaceG {
        type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
        unique: MaybeG Boolean
        sparse: MaybeG Boolean
      }]),
        default: (collection_name, field_names, options)-> yield return

      @public @async removeTimestamps: FuncG([String, MaybeG Object]),
        default: (collection_name, options = {})->
          collectionName = "#{inflect.camelize collection_name}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          for own id, doc of memCollection[ipoCollection]
            delete doc.createdAt
            delete doc.updatedAt
            delete doc.deletedAt
          yield return


      @initializeMixin()
