inflect = do require 'i'
_ = require 'lodash'
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
          not /Mixin$|Interface$|^CoreObject$|^Record$/.test name
        inflect.pluralize inflect.underscore firstClassName

    @public collectionPrefix: Function,
      default: -> "#{inflect.underscore @Module.name}_" # может быть вместо @Module заиспользовать @getData().Module

    @public collectionFullName: Function,
      default: (asName = null)->
        "#{@collectionPrefix()}#{asName ? @collectionName()}"

    @public recordHasBeenChanged: Function,
      default: (aoType, aoData)->
        @facade.sendNotification LeanRC::Constants.RECORD_CHANGED, aoData, aoType

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

    @public delete: Function,
      default: (id)->
        voRecord = @find id
        voRecord.delete()
        return voRecord

    @public destroy: Function,
      default: (id)->
        voRecord = @find id
        voRecord.destroy()
        return

    @public find: Function,
      default: (id)->
        @take id

    @public findMany: Function,
      default: (ids)->
        @takeMany ids

    @public replace: Function,
      default: (id, properties)->
        voRecord = @find id
        voRecord # ????????????
        return voRecord

    @public update: Function,
      default: (id, properties)->
        voRecord = @find id
        voRecord.updateAttributes properties
        return voRecord

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

    @public normalize: Function,
      default: (ahData)->
        @serializer.normalize @delegate, ahData

    @public serialize: Function,
      default: (aoRecord, ahOptions)->
        @serializer.serialize aoRecord, ahOptions


  return LeanRC::Collection.initialize()
