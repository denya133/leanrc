

module.exports = (Module)->
  {
    PointerT
    FuncG, UnionG, ListG, DictG, MaybeG
    RecordInterface, CursorInterface
    Collection, Mixin
    Utils: { _, inflect, uuid }
  } = Module::

  Module.defineMixin Mixin 'MemoryCollectionMixin', (BaseClass = Collection) ->
    class extends BaseClass
      @inheritProtected()

      ipoCollection = PointerT @protected collection: DictG UnionG(String, Number), MaybeG Object

      @public onRegister: Function,
        default: (args...)->
          @super args...
          @[ipoCollection] = {}
          return

      @public @async push: FuncG(RecordInterface, RecordInterface),
        default: (aoRecord)->
          vsKey = aoRecord.id
          return no  unless vsKey?
          @[ipoCollection][vsKey] = yield @serializer.serialize aoRecord
          return yield Module::Cursor.new(@, [@[ipoCollection][vsKey]]).first()

      @public @async remove: FuncG([UnionG String, Number]),
        default: (id)->
          delete @[ipoCollection][id]
          yield return

      @public @async take: FuncG([UnionG String, Number], MaybeG RecordInterface),
        default: (id)->
          return yield Module::Cursor.new(@, [@[ipoCollection][id]]).first()

      @public @async takeMany: FuncG([ListG UnionG String, Number], CursorInterface),
        default: (ids)->
          yield return Module::Cursor.new @, ids.map (id)=>
            @[ipoCollection][id]

      @public @async takeAll: FuncG([], CursorInterface),
        default: ->
          yield return Module::Cursor.new @, _.values @[ipoCollection]

      @public @async override: FuncG([UnionG(String, Number), RecordInterface], RecordInterface),
        default: (id, aoRecord)->
          @[ipoCollection][id] = yield @serializer.serialize aoRecord
          return yield Module::Cursor.new(@, [@[ipoCollection][id]]).first()

      @public @async includes: FuncG([UnionG String, Number], Boolean),
        default: (id)->
          yield return @[ipoCollection][id]?

      @public @async length: FuncG([], Number),
        default: ->
          yield return Object.keys(@[ipoCollection]).length


      @initializeMixin()
