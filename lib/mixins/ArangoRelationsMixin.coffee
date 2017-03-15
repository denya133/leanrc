# этот миксин должен инклудиться в классах унаследованных от рекорда.
_             = require 'lodash'
joi           = require 'joi'
{ db }        = require '@arangodb'
qb            = require 'aqb'
inflect       = require('i')()
RC            = require 'RC'

SIMPLE_TYPES  = ['string', 'number', 'boolean', 'date', 'object']

###
```coffee


```
###

module.exports = (LeanRC)->
  require('./ArangoCursor') LeanRC
  class LeanRC::ArangoRelationsMixin extends RC::Mixin
    @inheritProtected()
    @implements LeanRC::RelationsMixinInterface

    @Module: LeanRC

    @public @static relations: Object,
      default: {}
      get: (__relations)->
        fromSuper = if @__super__?
          @__super__.constructor.relations
        __relations[@name] ?= do =>
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass["_#{@name}_relations"] ? {})
        __relations[@name]

    # не является платформозависимым
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
            vcRecord = opts.transform()
            ipoFacade = Symbol.for 'facade'
            vsCollectionName = "#{inflect.pluralize vcRecord.name}Collection"
            voCollection = @collection[ipoFacade].retrieveProxy vsCollectionName
            unless through
              @collection.take "@doc.#{refKey}": @[attr]
                .first()
            else
              @collection.query
                $forIn:
                  "@current": @collection.collectionFullName()
                $forIn:
                  "@edge": @collection.collectionFullName(opts.through[0])
                $forIn:
                  "@destination": voCollection.collectionFullName()
                $join: switch opts.through[1].as
                  when 'OUTBOUND'
                    $and: [
                      '@edge._from': {$eq: '@current._id'}
                      '@edge._to': {$eq: '@destination._id'}
                    ]
                  when 'INBOUND'
                    $and: [
                      '@edge._from': {$eq: '@destination._id'}
                      '@edge._to': {$eq: '@current._id'}
                    ]
                $filter:
                  '@current._key': {$eq: @_key}
                $limit: 1
                $return: '@destination'
              .first()
        @computed "#{vsAttr}": LeanRC::RecordInterface, opts
        @["_#{@name}_relations"] ?= {}
        @["_#{@name}_relations"][vsAttr] = opts
        return

    # не является платформозависимым
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
          vcRecord = opts.transform()
          ipoFacade = Symbol.for 'facade'
          vsCollectionName = "#{inflect.pluralize vcRecord.name}Collection"
          voCollection = @collection[ipoFacade].retrieveProxy vsCollectionName
          unless opts.through
            @collection.take "@doc.#{opts.inverse}": @[opts.refKey]
          else
            @collection.query
              $forIn:
                "@current": @collection.collectionFullName()
              $forIn:
                "@edge": @collection.collectionFullName(opts.through[0])
              $forIn:
                "@destination": voCollection.collectionFullName()
              $join: switch opts.through[1].as
                when 'OUTBOUND'
                  $and: [
                    '@edge._from': {$eq: '@current._id'}
                    '@edge._to': {$eq: '@destination._id'}
                  ]
                when 'INBOUND'
                  $and: [
                    '@edge._from': {$eq: '@destination._id'}
                    '@edge._to': {$eq: '@current._id'}
                  ]
              $filter:
                '@current._key': {$eq: @_key}
              $return: '@destination'
        @computed "#{vsAttr}": LeanRC::CursorInterface, opts
        @["_#{@name}_relations"] ?= {}
        @["_#{@name}_relations"][vsAttr] = opts
        return

    # не является платформозависимым
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
          vcRecord = opts.transform()
          ipoFacade = Symbol.for 'facade'
          vsCollectionName = "#{inflect.pluralize vcRecord.name}Collection"
          voCollection = @collection[ipoFacade].retrieveProxy vsCollectionName
          @collection.take "@doc.#{opts.inverse}": @[opts.refKey]
            .first()
        @computed typeDefinition, opts
        @["_#{@name}_relations"] ?= {}
        @["_#{@name}_relations"][vsAttr] = opts
        return

    # Cucumber.inverseFor 'tomato' #-> {recordClass: App::Tomato, attrName: 'cucumbers', relation: 'hasMany'}
    @public @static inverseFor: Function,
      default: (asAttrName)->
        vhRelationConfig = @relations[asAttrName]
        recordClass = vhRelationConfig.transform()
        {inverse:attrName} = vhRelationConfig
        {relation} = recordClass.relations[attrName]
        return {recordClass, attrName, relation}


  return LeanRC::ArangoRelationsMixin.initialize()
