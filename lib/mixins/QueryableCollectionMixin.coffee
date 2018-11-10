
# миксин подмешивается к классам унаследованным от Module::Collection
# если необходимо реализовать работу методов с использованием абстрактного платформонезависимого класса Module::Query
# т.о. миксин с реальным платформозависимым кодом для подмешивания в наследников
# Module::Collection должен содержать только реализации 2-х методов:
# `parseQuery` и `executeQuery`


module.exports = (Module)->
  {
    NilT
    FuncG, UnionG, MaybeG
    QueryInterface
    CursorInterface
    QueryableCollectionInterface
    Collection
    Mixin
    Utils: { co, _ }
  } = Module::

  Module.defineMixin Mixin 'QueryableCollectionMixin', (BaseClass = Collection) ->
    class extends BaseClass
      @inheritProtected()
      @implements QueryableCollectionInterface

      @public @async findBy: FuncG([Object, MaybeG Object], CursorInterface),
        default: (query, options = {})->
          return yield @takeBy query, options

      @public @async takeBy: FuncG([Object, MaybeG Object], CursorInterface),
        default: ->
          throw new Error 'Not implemented specific method'
          yield return

      @public @async deleteBy: FuncG(Object, NilT),
        default: (query)->
          voRecordsCursor = yield @takeBy query
          yield voRecordsCursor.forEach co.wrap (aoRecord)->
            return yield aoRecord.delete()
          yield return

      @public @async destroyBy: FuncG(Object, NilT),
        default: (query)->
          voRecordsCursor = yield @takeBy query
          yield voRecordsCursor.forEach co.wrap (aoRecord)->
            return yield aoRecord.destroy()
          yield return

      @public @async removeBy: FuncG(Object, NilT),
        default: (query)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter query
            .remove()
            .into @collectionFullName()
          yield @query voQuery
          yield return

      @public @async updateBy: FuncG([Object, Object], NilT),
        default: (query, properties)->
          voRecordsCursor = yield @takeBy query
          yield voRecordsCursor.forEach co.wrap (aoRecord)->
            return yield aoRecord.updateAttributes properties
          yield return

      @public @async patchBy: FuncG([Object, Object], NilT),
        default: (query, properties)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter query
            .patch properties
            .into @collectionFullName()
          yield @query voQuery
          yield return

      @public @async exists: FuncG(Object, Boolean),
        default: (query)->
          voQuery = Module::Query.new()
            .forIn '@doc': @collectionFullName()
            .filter query
            .limit 1
            .return '@doc'
          cursor = yield @query voQuery
          return yield cursor.hasNext()

      @public @async query: FuncG([UnionG Object, QueryInterface], CursorInterface),
        default: (aoQuery)->
          if _.isPlainObject aoQuery
            aoQuery = _.pick aoQuery, Object.keys(aoQuery).filter (key)-> aoQuery[key]?
            voQuery = Module::Query.new aoQuery
          else
            voQuery = aoQuery
          return yield @executeQuery yield @parseQuery voQuery

      @public @async parseQuery: FuncG(
        [UnionG Object, QueryInterface]
        UnionG Object, String, QueryInterface
      ),
        default: ->
          throw new Error 'Not implemented specific method'
          yield return

      @public @async executeQuery: FuncG(
        [UnionG Object, String, QueryInterface]
        CursorInterface
      ),
        default: ->
          throw new Error 'Not implemented specific method'
          yield return


      @initializeMixin()
