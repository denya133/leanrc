_             = require 'lodash'
inflect       = do require 'i'


module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineMixin (BaseClass) ->
    class MemoryMigrationMixin extends BaseClass
      @inheritProtected()

      @public @async createCollection: Function,
        default: (name, options)->
          yield return

      @public @async createEdgeCollection: Function,
        default: (collection_1, collection_2, options)->
          yield return

      @public @async addField: Function,
        default: (collection_name, field_name, options = {})->
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
            doc[field_name] = initial
          yield return

      @public @async addIndex: Function,
        default: (collection_name, field_names, options)->
          yield return

      @public @async addTimestamps: Function,
        default: (collection_name, options)->
          collectionName = "#{inflect.camelize collection_name}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          for own id, doc of memCollection[ipoCollection]
            doc.createdAt ?= null
            doc.updatedAt ?= null
            doc.deletedAt ?= null
          yield return

      @public @async changeCollection: Function,
        default: (name, options)->
          yield return

      @public @async changeField: Function,
        default: (collection_name, field_name, options)->
          {
            json
            binary
            boolean
            date
            datetime
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
          for own id, doc of memCollection[ipoCollection]
            switch options.type
              when boolean
                doc[field_name] = Boolean doc[field_name]
              when decimal, float, integer
                doc[field_name] = Number doc[field_name]
              when string, text, primary_key, binary
                doc[field_name] = String JSON.stringify doc[field_name]
              when json, hash, array
                doc[field_name] = JSON.parse String doc[field_name]
              when date, datetime
                doc[field_name] = new Date(String  doc[field_name]).toISOString()
              when time, timestamp
                doc[field_name] = new Date(String  doc[field_name]).getTime()
            return
          yield return

      @public @async renameField: Function,
        default: (collection_name, field_name, new_field_name)->
          collectionName = "#{inflect.camelize collection_name}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          for own id, doc of memCollection[ipoCollection]
            doc[new_field_name] = doc[field_name]
            delete doc[field_name]
            return
          yield return

      @public @async renameIndex: Function,
        default: (collection_name, old_name, new_name)->
          yield return

      @public @async renameCollection: Function,
        default: (collection_name, old_name, new_name)->
          yield return

      @public @async dropCollection: Function,
        default: (collection_name)->
          collectionName = "#{inflect.camelize collection_name}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          for own id, doc of @collection[ipoCollection]
            delete memCollection[ipoCollection][id]
            return
          delete memCollection[ipoCollection]
          memCollection[ipoCollection] = {}
          yield return

      @public @async dropEdgeCollection: Function,
        default: (collection_1, collection_2)->
          qualifiedName = "#{collection_1}_#{collection_2}"
          collectionName = "#{inflect.camelize qualifiedName}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          for own id, doc of @collection[ipoCollection]
            delete memCollection[ipoCollection][id]
            return
          delete memCollection[ipoCollection]
          memCollection[ipoCollection] = {}
          yield return

      @public @async removeField: Function,
        default: (collection_name, field_name)->
          collectionName = "#{inflect.camelize collection_name}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          for own id, doc of memCollection[ipoCollection]
            delete doc[field_name]
            return
          yield return

      @public @async removeIndex: Function,
        default: (collection_name, field_names, options)->
          yield return

      @public @async removeTimestamps: Function,
        default: (collection_name, options)->
          collectionName = "#{inflect.camelize collection_name}Collection"
          memCollection = @collection.facade.retrieveProxy collectionName
          ipoCollection = Symbol.for '~collection'
          for own id, doc of memCollection[ipoCollection]
            delete doc.createdAt
            delete doc.updatedAt
            delete doc.deletedAt
            return
          yield return


    MemoryMigrationMixin.initializeMixin()
