# миксин подмешивается к классам унаследованным от Module::Collection
# если необходимы методы для работы с collection как с итерируемым объектом


module.exports = (Module)->
  class IterableMixin extends Module::Mixin
    @inheritProtected()
    @implements Module::IterableMixinInterface

    @Module: Module

    @public @async forEach: Function,
      default: (lambda)->
        cursor = yield @takeAll()
        cursor.forEach (item)-> yield lambda item
        return

    @public @async filter: Function,
      default: (lambda)->
        cursor = yield @takeAll()
        cursor.filter (item)-> yield lambda item

    @public @async map: Function,
      default: (lambda)->
        cursor = yield @takeAll()
        cursor.map (item)-> yield lambda item

    @public @async reduce: Function,
      default: (lambda, initialValue)->
        cursor = yield @takeAll()
        cursor.reduce ((item, prev)-> yield lambda item, prev), initialValue


  IterableMixin.initialize()
