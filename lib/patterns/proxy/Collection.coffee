# так как в этом репозитории нельзя давать платформозависимый код,
# данный класс (миксин) нужен 1 - для примера реализации интерфейса, 2 - так как ориентирован на хранение данных в оперативной памяти - то является платформонезависимым решением, 3 - может быть полезен при написании конкретных программ где данные должны храниться в оперативной памяти.

RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Collection extends LeanRC::Proxy
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


    @public build: Function,
      default: (properties)->
        @delegate.new properties

    @public create: Function,
      default: (properties)->
        voRecord = @build properties
        voRecord.save()

    @public push: Function,
      default: (aoRecord)->
        voQuery = LeanRC::Query.new()
          .insert aoRecord
          .into @collectionName()
        @query voQuery
        return yes


    @public delete: Function,
      default: (id)->
        voRecord = @find id
        voRecord.delete()
        return voRecord

    @public deleteBy: Function,
      default: (query)->
        @findBy query
          .forEach (aoRecord)-> aoRecord.delete()
        return


    @public destroy: Function,
      default: (id)->
        voRecord = @find id
        voRecord.destroy()
        return

    @public destroyBy: Function,
      default: (query)->
        @findBy query
          .forEach (aoRecord)-> aoRecord.destroy()
        return

    @public remove: Function,
      default: (query)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter query
          .remove()
        @query voQuery
        return yes


    @public find: Function,
      default: (id)->
        @take '@doc._key': {$eq: id}
          .first()

    @public findBy: Function,
      default: (query)->
        @take query

    @public take: Function,
      default: (query)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter query
          .return '@doc'
        return @query voQuery


    @public replace: Function,
      default: (id, properties)->
        voRecord = @find id
        voRecord. # ????????????
        return voRecord

    @public replaceBy: Function,
      default: (query, properties)->
        @findBy query
          .forEach (aoRecord)-> aoRecord. #??????????????
        return

    @public override: Function,
      default: (query, aoRecord)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter query
          .replace aoRecord
        return @query voQuery


    @public update: Function,
      default: (id, properties)->
        voRecord = @find id
        voRecord.updateAttributes properties
        return voRecord

    @public updateBy: Function,
      default: (query, properties)->
        @findBy query
          .forEach (aoRecord)-> aoRecord.updateAttributes properties
        return

    @public patch: Function,
      default: (query, aoRecord)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter query
          .update aoRecord
        return @query voQuery


    @public clone: Function,
      default: (aoRecord)->
        voRecord = @delegate.new aoRecord
        voRecord.id = @generateId()
        return voRecord

    @public copy: Function,
      default: (aoRecord)->
        voRecord = @clone aoRecord
        voRecord.save()
        return voRecord


    @public forEach: Function,
      default: (lambda)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .return '@doc'
        @query voQuery
          .forEach lambda
        return

    @public filter: Function,
      default: (lambda)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .return '@doc'
        return @query voQuery
          .filter lambda

    @public map: Function,
      default: (lambda)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .return '@doc'
        return @query voQuery
          .map lambda

    @public reduce: Function,
      default: (lambda, initialValue)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .return '@doc'
        return @query voQuery
          .reduce lambda, initialValue


    @public includes: Function,
      default: (id)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter '@doc._key': {$eq: id}
          .limit 1
          .return '@doc'
        return @query voQuery
          .hasNext()

    @public exists: Function,
      default: (query)->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .filter query
          .limit 1
          .return '@doc'
        return @query voQuery
          .hasNext()

    @public length: Function, # количество объектов в коллекции
      default: ->
        voQuery = LeanRC::Query.new()
          .forIn '@doc': @collectionName()
          .count()
        return @query voQuery
          .first()


    @public normalize: Function,
      default: (ahData)->
        @serializer.normalize @delegate, ahData

    @public serialize: Function,
      default: (aoRecord, ahOptions)->
        @serializer.serialize aoRecord, ahOptions


    @public query: Function,
      default: (query)->
        query = _.pick query, Object.keys(query).filter (key)-> query[key]?
        voQuery = LeanRC::Query.new query
        return @executeQuery @parseQuery voQuery

    @public parseQuery: Function,
      default: (query)->
        return query

    @public executeQuery: Function,
      default: (query, options)->
        return result


  return LeanRC::Collection.initialize()
