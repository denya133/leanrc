

RC = require 'RC'

# миксин подмешивается к классам унаследованным от LeanRC::Collection
# если необходимы методы для работы с collection как с итерируемым объектом


module.exports = (LeanRC)->
  class LeanRC::IterableMixin extends RC::Mixin
    @inheritProtected()
    @implements LeanRC::IterableMixinInterface

    @Module: LeanRC

    @public forEach: Function,
      default: (lambda)->
        @takeAll().forEach lambda
        return

    @public filter: Function,
      default: (lambda)->
        @takeAll().filter lambda

    @public map: Function,
      default: (lambda)->
        @takeAll().map lambda

    @public reduce: Function,
      default: (lambda, initialValue)->
        @takeAll().reduce lambda, initialValue


  return LeanRC::IterableMixin.initialize()
