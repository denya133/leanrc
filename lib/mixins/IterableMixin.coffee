

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
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionFullName()
          .return '@doc'
        @query voQuery
          .forEach lambda
        return

    @public filter: Function,
      default: (lambda)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionFullName()
          .return '@doc'
        return @query voQuery
          .filter lambda

    @public map: Function,
      default: (lambda)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionFullName()
          .return '@doc'
        return @query voQuery
          .map lambda

    @public reduce: Function,
      default: (lambda, initialValue)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionFullName()
          .return '@doc'
        return @query voQuery
          .reduce lambda, initialValue


  return LeanRC::IterableMixin.initialize()
