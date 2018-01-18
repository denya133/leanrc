
# миксин подмешивается к классам унаследованным от Module::Collection
# если необходимо реализовать работу методов с использованием абстрактного платформонезависимого класса Module::Query
# т.о. миксин с реальным платформозависимым кодом для подмешивания в наследников
# Module::Collection должен содержать только реализации 2-х методов:
# `parseQuery` и `executeQuery`


module.exports = (Module)->
  {
    Collection
    Utils: { co, _ }
  } = Module::

  Module.defineMixin 'QueryableCollectionMixin', (BaseClass = Collection) ->
    class extends BaseClass
      @inheritProtected()
      # @implements Module::QueryableCollectionMixinInterface

      @public @async findBy: Function,
        default: (query, options = {})->
          return yield @takeBy query, options

      @public @async deleteBy: Function,
        default: (query)->
          voRecordsCursor = yield @takeBy query
          yield voRecordsCursor.forEach co.wrap (aoRecord)->
            return yield aoRecord.delete()
          yield return

      @public @async destroyBy: Function,
        default: (query)->
          voRecordsCursor = yield @takeBy query
          yield voRecordsCursor.forEach co.wrap (aoRecord)->
            return yield aoRecord.destroy()
          yield return

      @public @async removeBy: Function,
        default: (query)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter query
            .remove()
            .into @collectionFullName()
          yield @query voQuery
          yield return

      @public @async updateBy: Function,
        default: (query, properties)->
          voRecordsCursor = yield @takeBy query
          yield voRecordsCursor.forEach co.wrap (aoRecord)->
            return yield aoRecord.updateAttributes properties
          yield return

      @public @async patchBy: Function,
        default: (query, properties)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter query
            .patch properties
            .into @collectionFullName()
          yield @query voQuery
          yield return

      @public @async exists: Function,
        default: (query)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter query
            .limit 1
            .return '@doc'
          cursor = yield @query voQuery
          return yield cursor.hasNext()

      @public @async query: Function,
        default: (aoQuery)->
          if _.isPlainObject aoQuery
            aoQuery = _.pick aoQuery, Object.keys(aoQuery).filter (key)-> aoQuery[key]?
            voQuery = Module::Query.new aoQuery
          else
            voQuery = aoQuery
          return yield @executeQuery yield @parseQuery voQuery


      @initializeMixin()
