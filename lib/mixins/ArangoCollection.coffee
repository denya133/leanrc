# надо реализовать в отдельном модуле (npm-пакете) так как является платформозависимым
# эта реализация должна имплементировать интерфейс CollectionInterface
# но для хранения и получения данных должна обращаться к ArangoDB коллекциям.

_             = require 'lodash'
joi           = require 'joi'
{ db }        = require '@arangodb'
qb            = require 'aqb'
crypto        = require '@arangodb/crypto'
inflect       = require('i')()
fs            = require 'fs'
RC            = require 'RC'

SIMPLE_TYPES  = ['string', 'number', 'boolean', 'date', 'object']


module.exports = (LeanRC)->
  class LeanRC::ArangoCollection extends LeanRC::Proxy
    @inheritProtected()
    @implements LeanRC::CollectionInterface

    @Module: LeanRC

    @public delegate: RC::Class # устанавливается при инстанцировании прокси
    @public serializer: RC::Class # устанавливается при инстанцировании прокси

    @public collectionName: Function,
      default: ->
        firstClassName = _.first _.remove @delegate.parentClassNames(), (name)->
          not (/Mixin$/.test(name) or not (/Interface$/.test(name) or name in ['CoreObject', 'Record'])
        inflect.pluralize inflect.underscore firstClassName

    @public collectionPrefix: Function,
      default: -> "#{inflect.underscore @Module.name}_" # может быть вместо @Module заиспользовать @getData().Module

    @public collectionFullName: Function,
      default: (asName = null)->
        "#{@collectionPrefix()}#{asName ? @collectionName()}"

    @public customFilters: Object, # возвращает установленные кастомные фильтры с учетом наследования
      default: {}
      get: (__customFilters)->
        AbstractClass = @
        fromSuper = if AbstractClass.__super__?
          AbstractClass.__super__.constructor.customFilters
        __customFilters[AbstractClass.name] ?= do ->
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass["_#{AbstractClass.name}_customFilters"] ? {})
        __customFilters[AbstractClass.name]

    @public customFilter: Function,
      default: (asFilterName, aoStatement)->
        if _.isObject aoStatement
          config = aoStatement
        else if _.isFunction aoStatement
          config = aoStatement.apply @, []
        @["_#{@name}_customFilters"] ?= {}
        @["_#{@name}_customFilters"][asFilterName] = config
        return

    @public generateId: Function,
      default: -> return

    @public create: Function,
      default: (properties)->
        @delegate.new properties

    @public createDirectly: Function,
      default: (properties)->
        return record

    @public insert: Function,
      default: (properties)->
        voQuery = LeanRC::Query.new()
          .insert properties
          .into @collectionName()
        return @executeQuery @parseQuery voQuery
          .first()

    @public delete: Function,
      default: (id)->
        record = @find id
        record.delete()
        return record

    @public deleteBy: Function,
      default: (query)->
        record = @findBy id
        record.delete()
        return record

    @public destroy: Function,
      default: (id)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter '@doc._key': {$eq: id}
          .remove()
        return @executeQuery @parseQuery voQuery
          .first()

    @public destroyBy: Function,
      default: (query)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter query
          .remove()
        return @executeQuery @parseQuery voQuery

    @public find: Function,
      default: (id)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter '@doc._key': {$eq: id}
          .limit 1
          .return '@doc'
        voRecord = @executeQuery @parseQuery voQuery
          .first()
        return voRecord

    @public findBy: Function,
      default: (query)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter query
          .limit 1
          .return '@doc'
        return @executeQuery @parseQuery voQuery
          .first()

    @public filter: Function,
      default: (query)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter query
          .return '@doc'
        return @executeQuery @parseQuery voQuery

    @public update: Function,
      default: (id, properties)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter '@doc._key': {$eq: id}
          .update properties
        return @executeQuery @parseQuery voQuery
          .first()

    @public updateBy: Function,
      default: (query, properties)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter query
          .update properties
        return @executeQuery @parseQuery voQuery

    @public query: Function,
      default: (query)->
        query = _.pick query, Object.keys(query).filter (key)-> query[key]?
        voQuery = LeanRC::Query.new query
        return @executeQuery @parseQuery voQuery

    @public copy: Function,
      default: (id)->
        return record
    @public deepCopy: Function,
      default: (id)->
        return record

    @public forEach: Function,
      default: (lambda)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .return '@doc'
        @executeQuery @parseQuery voQuery
          .forEach lambda
        return

    @public map: Function,
      default: (lambda)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .return '@doc'
        return @executeQuery @parseQuery voQuery
          .map lambda

    @public reduce: Function,
      default: (lambda, initialValue)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .return '@doc'
        return @executeQuery @parseQuery voQuery
          .reduce lambda, initialValue

    @public includes: Function,
      default: (id)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter '@doc._key': {$eq: id}
          .limit 1
          .return '@doc'
        return @executeQuery @parseQuery voQuery
          .hasNext()

    @public exists: Function,
      default: (query)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter query
          .limit 1
          .return '@doc'
        return @executeQuery @parseQuery voQuery
          .hasNext()

    @public length: Function, # количество объектов в коллекции
      default: ->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .count()
        return @executeQuery @parseQuery voQuery
          .first()

    @public push: Function,
      default: (data)->
        return isPushed
    @public normalize: Function,
      default: (data)->
        return data
    @public serialize: Function,
      default: (id, options)->
        return data
    @public unload: Function,
      default: (id)->
        return
    @public unloadBy: Function,
      default: (query)->
        return
    @public parseQuery: Function,
      default: (query)->
        return query
    @public executeQuery: Function,
      default: (query, options)->
        return result


  return LeanRC::ArangoCollection.initialize()
