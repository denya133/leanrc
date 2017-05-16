# миксин подмешивается к классам унаследованным от Module::Collection
# если необходимы методы для работы с collection как с итерируемым объектом


module.exports = (Module)->
  Module.defineMixin Module::Collection, (BaseClass) ->
    class IterableMixin extends BaseClass
      @inheritProtected()
      @implements Module::IterableMixinInterface

      @public @async forEach: Function,
        default: (lambda)->
          cursor = yield @takeAll()
          yield cursor.forEach (item)-> yield lambda item
          return

      @public @async filter: Function,
        default: (lambda)->
          cursor = yield @takeAll()
          yield cursor.filter (item)-> yield lambda item

      @public @async map: Function,
        default: (lambda)->
          cursor = yield @takeAll()
          yield cursor.map (item)-> yield lambda item

      @public @async reduce: Function,
        default: (lambda, initialValue)->
          cursor = yield @takeAll()
          yield cursor.reduce ((item, prev)-> yield lambda item, prev), initialValue


    IterableMixin.initializeMixin()
