# миксин подмешивается к классам унаследованным от Module::Collection
# если необходимы методы для работы с collection как с итерируемым объектом


module.exports = (Module)->
  {
    AnyT
    FuncG
    IterableInterface
    Collection
    Mixin
  } = Module::

  Module.defineMixin Mixin 'IterableMixin', (BaseClass = Collection) ->
    class extends BaseClass
      @inheritProtected()
      @implements IterableInterface

      @public @async forEach: FuncG(Function),
        default: (lambda)->
          cursor = yield @takeAll()
          yield cursor.forEach (item)-> yield lambda item
          return

      @public @async filter: FuncG(Function, Array),
        default: (lambda)->
          cursor = yield @takeAll()
          yield cursor.filter (item)-> yield lambda item

      @public @async map: FuncG(Function, Array),
        default: (lambda)->
          cursor = yield @takeAll()
          yield cursor.map (item)-> yield lambda item

      @public @async reduce: FuncG([Function, AnyT], AnyT),
        default: (lambda, initialValue)->
          cursor = yield @takeAll()
          yield cursor.reduce ((prev, item)-> yield lambda prev, item), initialValue


      @initializeMixin()
