# вычленяем из Record'а все что связано с релейшенами, т.к. Рекорды на основе key-value базы данных (Redis-like) не смогут поддерживать связи - т.к. на фундаментальном уровне кроме поиска по id в них нереализован поиск по НЕ-первичным ключам или сложным условиям
_ = require 'lodash'
joi = require 'joi'
inflect = do require 'i'

RC = require 'RC'

# миксин для подмешивания в классы унаследованные от LeanRC::Record
# если в этих классах необходим функционал релейшенов.


module.exports = (LeanRC)->
  class LeanRC::RelationsMixin extends RC::Mixin
    @inheritProtected()
    @implements LeanRC::RelationsMixinInterface

    @Module: LeanRC

    cphRelations  = @protected @static relationsPointer: Symbol,
      get: -> Symbol.for "~relations_#{@moduleName()}_#{@name}"

    @public @static relations: Object,
      default: {}
      get: (__relations)->
        AbstractClass = @
        fromSuper = if AbstractClass.__super__?
          AbstractClass.__super__.constructor.relations
        __relations[AbstractClass[cphRelations]] ?= do ->
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass[AbstractClass[cphRelations]] ? {})
        __relations[AbstractClass[cphRelations]]

    @public @static belongsTo: Function,
      default: (typeDefinition, {attr, refKey, get, set, transform, through, inverse, valuable, sortable, groupable, filterable}={})->
        # TODO: возможно для фильтрации по этому полю, если оно valuable надо как-то зайдествовать customFilters
        vsAttr = Object.keys(typeDefinition)[0]
        attr ?= "#{vsAttr}Id"
        refKey ?= '_key'
        @attribute "#{attr}": String
        if attr isnt "#{vsAttr}Id"
          @computed "#{vsAttr}Id": String,
            valuable: "#{vsAttr}Id"
            filterable: "#{vsAttr}Id"
            set: (aoData)->
              aoData = set?.apply(@, [aoData]) ? aoData
              @[attr] = aoData
              return
            get: ->
              get?.apply(@, [@[attr]]) ? @[attr]
        opts =
          valuable: valuable
          sortable: sortable
          groupable: groupable
          filterable: filterable
          transform: transform ? =>
            [vsModuleName, vsRecordName] = @parseRecordName vsAttr
            @Module::[vsRecordName]
          validate: -> opts.transform().schema
          inverse: inverse ? "#{inflect.pluralize inflect.camelize @name, no}"
          relation: 'belongsTo'
          set: (aoData)->
            if (id = aoData?[refKey])?
              @[attr] = id
              return
            else
              @[attr] = null
              return
          get: ->
            RC::Utils.co =>
              vcRecord = opts.transform()
              vsCollectionName = "#{inflect.pluralize vcRecord.name}Collection"
              voCollection = @collection.facade.retrieveProxy vsCollectionName
              unless through
                cursor = yield voCollection.takeBy "@doc.#{refKey}": @[attr]
                cursor.first()
              else
                if @[through[0]]?[0]?
                  yield voCollection.take @[through[0]][0][through[1].by]
                else
                  null
        @computed @async "#{vsAttr}": LeanRC::RecordInterface, opts
        @[@[cphRelations]] ?= {}
        @[@[cphRelations]][vsAttr] = opts
        return

    @public @static hasMany: Function,
      default: (typeDefinition, opts={})->
        vsAttr = Object.keys(typeDefinition)[0]
        opts.refKey ?= '_key'
        opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
        opts.relation = 'hasMany'
        opts.transform ?= =>
            [vsModuleName, vsRecordName] = @parseRecordName vsAttr
            @Module::[vsRecordName]
        opts.validate = -> joi.array().items opts.transform().schema
        opts.get = ->
          RC::Utils.co =>
            vcRecord = opts.transform()
            vsCollectionName = "#{inflect.pluralize vcRecord.name}Collection"
            voCollection = @collection.facade.retrieveProxy vsCollectionName
            unless opts.through
              yield voCollection.takeBy "@doc.#{opts.inverse}": @[opts.refKey]
            else
              if @[opts.through[0]]?
                throughItems = yield @[opts.through[0]]
                yield voCollection.takeMany throughItems.map (i)->
                  i[opts.through[1].by]
              else
                null
        @computed @async "#{vsAttr}": LeanRC::CursorInterface, opts
        @[@[cphRelations]] ?= {}
        @[@[cphRelations]][vsAttr] = opts
        return

    @public @static hasOne: Function,
      default: (typeDefinition, opts={})->
        # TODO: возможно для фильтрации по этому полю, если оно valuable надо как-то зайдествовать customFilters
        vsAttr = Object.keys(typeDefinition)[0]
        opts.refKey ?= '_key'
        opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
        opts.relation = 'hasOne'
        opts.transform ?= =>
            [vsModuleName, vsRecordName] = @parseRecordName vsAttr
            @Module::[vsRecordName]
        opts.validate = -> opts.transform().schema
        opts.get = ->
          RC::Utils.co =>
            vcRecord = opts.transform()
            vsCollectionName = "#{inflect.pluralize vcRecord.name}Collection"
            voCollection = @collection.facade.retrieveProxy vsCollectionName
            cursor = yield voCollection.takeBy "@doc.#{opts.inverse}": @[opts.refKey]
            cursor.first()
        @computed @async typeDefinition, opts
        @[@[cphRelations]] ?= {}
        @[@[cphRelations]][vsAttr] = opts
        return

    # Cucumber.inverseFor 'tomato' #-> {recordClass: App::Tomato, attrName: 'cucumbers', relation: 'hasMany'}
    @public @static inverseFor: Function,
      default: (asAttrName)->
        vhRelationConfig = @relations[asAttrName]
        recordClass = vhRelationConfig.transform()
        {inverse:attrName} = vhRelationConfig
        {relation} = recordClass.relations[attrName]
        return {recordClass, attrName, relation}

    @public @static initialize: Function,
      default: (args...) ->
        @super args...
        vlKeys = Reflect.ownKeys @
        for key in vlKeys
          switch key.toString()
            # when 'Symbol(_attributes)'
            #   @[key]?[@[cphAttributes]] = null
            # when 'Symbol(_edges)'
            #   @[key]?[@[cphEdges]] = null
            # when 'Symbol(_computeds)'
            #   @[key]?[@[cphEdges]] = null
            when 'Symbol(_relations)'
              @[key]?[@[cphRelations]] = null
        return


  return LeanRC::RelationsMixin.initialize()
