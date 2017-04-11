

_ = require 'lodash'
RC = require 'RC'

# миксин подмешивается к классам унаследованным от LeanRC::Collection
# если необходимо реализовать работу методов с использованием абстрактного платформонезависимого класса LeanRC::Query
# т.о. миксин с реальным платформозависимым кодом для подмешивания в наследников
# LeanRC::Collection должен содержать только реализации 2-х методов:
# `parseQuery` и `executeQuery`


module.exports = (LeanRC)->
  class LeanRC::QueryableMixin extends RC::Mixin
    @inheritProtected()
    @implements LeanRC::QueryableMixinInterface

    @Module: LeanRC

    @public findBy: Function,
      default: (query)->
        @takeBy query

    @public deleteBy: Function,
      default: (query)->
        @takeBy query
          .forEach (aoRecord)-> aoRecord.delete()
        return

    @public destroyBy: Function,
      default: (query)->
        @takeBy query
          .forEach (aoRecord)-> aoRecord.destroy()
        return

    @public removeBy: Function,
      default: (query)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionFullName()
          .filter query
          .remove()
        @query voQuery
        return yes

    @public takeBy: Function,
      default: (query)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionFullName()
          .filter query
          .return '@doc'
        return @query voQuery

    @public replaceBy: Function,
      default: (query, properties)->
        @takeBy query
          .forEach (aoRecord)-> aoRecord #??????????????
        return

    @public overrideBy: Function,
      default: (query, aoRecord)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionFullName()
          .filter query
          .replace aoRecord
        return @query voQuery

    @public updateBy: Function,
      default: (query, properties)->
        @takeBy query
          .forEach (aoRecord)-> aoRecord.updateAttributes properties
        return

    @public patchBy: Function,
      default: (query, aoRecord)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionFullName()
          .filter query
          .update aoRecord
        return @query voQuery

    @public exists: Function,
      default: (query)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionFullName()
          .filter query
          .limit 1
          .return '@doc'
        return @query voQuery
          .hasNext()

    @public query: Function,
      default: (aoQuery)->
        if aoQuery.constructor is LeanRC::Query
          voQuery = aoQuery
        else
          aoQuery = _.pick aoQuery, Object.keys(aoQuery).filter (key)-> aoQuery[key]?
          voQuery = LeanRC::Query.new aoQuery
        return @executeQuery @parseQuery voQuery


  return LeanRC::QueryableMixin.initialize()
