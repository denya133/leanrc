

module.exports = (Module)->
  {
    ANY, NILL

    Utils: { _, inflect, uuid }
  } = Module::

  Module.defineMixin Module::Collection, (BaseClass) ->
    class MemoryCollectionMixin extends BaseClass
      @inheritProtected()

      ipoCollection = @protected collection: Object

      @public onRegister: Function,
        default: (args...)->
          @super args...
          @[ipoCollection] = {}
          return

      @public @async push: Function,
        default: (aoRecord)->
          vsKey = aoRecord.id
          return no  unless vsKey?
          @[ipoCollection][vsKey] = @serializer.serialize aoRecord
          yield return Module::Cursor.new(@, [@[ipoCollection][vsKey]]).first()

      @public @async remove: Function,
        default: (id)->
          delete @[ipoCollection][id]
          yield return yes

      @public @async take: Function,
        default: (id)->
          yield return Module::Cursor.new(@, [@[ipoCollection][id]]).first()

      @public @async takeMany: Function,
        default: (ids)->
          yield return Module::Cursor.new @, ids.map (id)=>
            @[ipoCollection][id]

      @public @async takeAll: Function,
        default: ->
          yield return Module::Cursor.new @, _.values @[ipoCollection]

      @public @async override: Function,
        default: (id, aoRecord)->
          @[ipoCollection][id] = @serializer.serialize aoRecord
          yield return Module::Cursor.new(@, [@[ipoCollection][id]]).first()

      @public @async patch: Function,
        default: (id, aoRecord)->
          @[ipoCollection][id] = @serializer.serialize aoRecord
          yield return Module::Cursor.new(@, [@[ipoCollection][id]]).first()

      @public @async includes: Function,
        default: (id)->
          yield return @[ipoCollection][id]?

      @public @async length: Function,
        default: ->
          yield return Object.keys(@[ipoCollection]).length


    MemoryCollectionMixin.initializeMixin()
