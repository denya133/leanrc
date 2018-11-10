# миксин подмешивается к классам унаследованным от Module::Collection
# если необходимы методы для работы с collection как с итерируемым объектом


module.exports = (Module)->
  {
    IterableInterface
    Collection
    Mixin
  } = Module::

  Module.defineMixin Mixin 'IterableMixin', (BaseClass = Collection) ->
    class extends BaseClass
      @inheritProtected()
      @implements IterableInterface

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
          yield cursor.reduce ((prev, item)-> yield lambda prev, item), initialValue


      @initializeMixin()
