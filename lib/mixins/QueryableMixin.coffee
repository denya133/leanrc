_ = require 'lodash'

# миксин подмешивается к классам унаследованным от Module::Collection
# если необходимо реализовать работу методов с использованием абстрактного платформонезависимого класса Module::Query
# т.о. миксин с реальным платформозависимым кодом для подмешивания в наследников
# Module::Collection должен содержать только реализации 2-х методов:
# `parseQuery` и `executeQuery`


module.exports = (Module)->
  Module.defineMixin 'QueryableMixin', (BaseClass) ->
    class QueryableMixin extends BaseClass
      @inheritProtected()
      @implements Module::QueryableMixinInterface

      @module Module

      @public @async findBy: Function,
        default: (query)->
          yield @takeBy query

      @public @async deleteBy: Function,
        default: (query)->
          vlRecords = yield @takeBy query
          yield vlRecords.forEach (aoRecord)-> yield aoRecord.delete()
          return

      @public @async destroyBy: Function,
        default: (query)->
          vlRecords = yield @takeBy query
          yield vlRecords.forEach (aoRecord)-> yield aoRecord.destroy()
          return

      @public @async @async removeBy: Function,
        default: (query)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter query
            .remove()
          yield @query voQuery
          return yes

      @public @async takeBy: Function,
        default: (query)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter query
            .return '@doc'
          yield @query voQuery

      @public @async replaceBy: Function,
        default: (query, properties)->
          vlRecords = yield @takeBy query
          yield vlRecords.forEach (aoRecord)->
            yield aoRecord.updateAttributes properties
          return

      @public @async overrideBy: Function,
        default: (query, aoRecord)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter query
            .replace aoRecord
          yield @query voQuery

      @public @async updateBy: Function,
        default: (query, properties)->
          vlRecords = yield @takeBy query
          yield vlRecords.forEach (aoRecord)->
            yield aoRecord.updateAttributes properties
          return

      @public @async patchBy: Function,
        default: (query, aoRecord)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter query
            .update aoRecord
          yield @query voQuery

      @public @async exists: Function,
        default: (query)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter query
            .limit 1
            .return '@doc'
          cursor = yield @query voQuery
          cursor.hasNext()

      @public @async query: Function,
        default: (aoQuery)->
          if aoQuery instanceof Module::Query
            voQuery = aoQuery
          else
            aoQuery = _.pick aoQuery, Object.keys(aoQuery).filter (key)-> aoQuery[key]?
            voQuery = Module::Query.new aoQuery
          yield @executeQuery @parseQuery voQuery


    QueryableMixin.initializeMixin()
