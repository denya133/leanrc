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

    @public @static properties: Object,
      default: {}
      get: (__props)->
        fromSuper = if @__super__?
          @__super__.constructor.properties
        __props[@name] ?= do =>
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass["_#{@name}_props"] ? {})
        __props[@name]

    @public @static property: Function,
      default: ->
        @prop arguments...
        return

    # @public @static prop: Function,
    #   default: (typeDefinition, opts={})->
    #     vsAttr = Object.keys(typeDefinition)[0]
    #     vcAttrType = typeDefinition[vsAttr]
    #     {
    #       attr, refKey, model,
    #       definition, bindings,
    #       valuable, valuableAs, sortable, groupable, filterable,
    #       get, set
    #     } = opts
    #     unless definition? and model?
    #       return throw new Error '`definition` and `model` options is required'
    #     if valuable?
    #       validate = =>
    #         unless model in SIMPLE_TYPES
    #           RecordClass = @findModelByName model
    #         return if model in ['string', 'boolean', 'number']
    #           joi[model]().empty(null).optional()
    #         else if model is 'date'
    #           joi.string().empty(null).optional()
    #         else if vcAttrType isnt Array and model is 'object'
    #           joi.object().empty(null).optional()
    #         else if vcAttrType is Array and model is 'object'
    #           joi.array().items joi.object().empty(null).optional()
    #         else if vcAttrType isnt Array and not /.*[.].*/.test valuable
    #           RecordClass.schema()
    #         else if vcAttrType isnt Array and /.*[.].*/.test valuable
    #           [..., prop_name] = valuable.split '.'
    #           RecordClass.attributes[prop_name].validate
    #         else if vcAttrType is Array and not /.*[.].*/.test valuable
    #           joi.array().items RecordClass.schema()
    #         else if vcAttrType is Array and /.*[.].*/.test valuable
    #           [..., prop_name] = valuable.split '.'
    #           joi.array().items RecordClass.attributes[prop_name].validate
    #     else
    #       validate = -> {}
    #     opts.validate ?= validate
    #     @["_#{@name}_props"] ?= {}
    #     model ?= inflect.singularize inflect.underscore vsAttr
    #     unless @["_#{@name}_props"][vsAttr]
    #       @["_#{@name}_props"][vsAttr] = opts
    #       switch vcAttrType
    #         when Array
    #           opts.get = ->
    #             RecordClass = null
    #             unless model in SIMPLE_TYPES
    #               RecordClass = @findModelByName model
    #               _bindings = RC::Utils.extend {}, bindings
    #               if _bindings.docKey is 'docKey'
    #                 _bindings.docKey = @_key
    #               if _bindings.docId is 'docId'
    #                 _bindings.docId = @_id
    #             console.log '$$$$$ hasMany.query definition, bindings', definition, _bindings
    #             LeanRC::ArangoCursor.new(RecordClass)
    #               .setCursor db._query definition, _bindings
    #           @public "#{vsAttr}": LeanRC::CursorInterface, opts
    #         else
    #           opts.get = ->
    #             RecordClass = null
    #             unless model in SIMPLE_TYPES
    #               RecordClass = @findModelByName model
    #             if (item = @["__#{vsAttr}"])?
    #               if model in SIMPLE_TYPES
    #                 return get?.apply(@, [item]) ? item
    #               if @[refKey ? '_key'] is item[refKey ? '_key']
    #                return @
    #               RecordClass.new item
    #             else if @["__#{vsAttr}"] is undefined
    #               _snapshot = @getSnapshot()
    #               _snapshot._id = "
    #                 #{@collection.collectionFullName()}/#{_snapshot._key}
    #               "
    #               _bindings = RS::Utils.extend {}, (bindings ? {}), {doc: _snapshot}
    #               _query = "
    #                   LET doc = (RETURN @doc)[0]
    #                   RETURN #{definition}
    #                 "
    #               console.log '???????????????????????KKKKKKKKKKKKKKKKKKKKKkk _query, _bindings', _query, _bindings
    #               item = LeanRC::ArangoCursor.new()
    #                 .setCursor db._query _query, _bindings
    #                 .next()
    #               @["__#{vsAttr}"] = item
    #               if model in SIMPLE_TYPES
    #                 return get?.apply(@, [item]) ? item
    #               if @[refKey ? '_key'] is item[refKey ? '_key']
    #                return @
    #               RecordClass.new item
    #             else
    #               null
    #           opts.set = (aoData)->
    #             if model in SIMPLE_TYPES
    #               set?.apply(@, [aoData]) ? aoData
    #             else
    #               if (id = aoData?[refKey ? '_key'])?
    #                 @[attr ? "#{vsAttr}Id"] = id
    #                 aoData
    #               else
    #                 @[attr ? "#{vsAttr}Id"] = null
    #                 null
    #           @public typeDefinition, opts
    #     else
    #       throw new Error "prop `#{vsAttr}` has been defined previously"
    #     return

    @public @static belongsTo: Function,
      default: (typeDefinition, opts={})->
        # TODO: возможно для фильтрации по этому полю, если оно valuable надо как-то зайдествовать customFilters
        vsAttr = Object.keys(typeDefinition)[0]
        opts.attr ?= "#{vsAttr}Id"
        opts.refKey ?= '_key'
        @attribute "#{opts.attr}": String #, opts
        if opts.attr isnt "#{vsAttr}Id"
          @computed "#{vsAttr}Id": String,
            valuable: "#{vsAttr}Id"
            filterable: "#{vsAttr}Id"
            set: (aoData)->
              aoData = opts.set?.apply(@, [aoData]) ? aoData
              @[opts.attr] = aoData
              return
            get: ->
              opts.get?.apply(@, [@[opts.attr]]) ? @[opts.attr]
        @computed "#{vsAttr}": LeanRC::RecordInterface,
          set: (aoData)->
            if (id = aoData?[opts.refKey])?
              @[opts.attr] = id
              return
            else
              @[opts.attr] = null
              return
          get: ->
            vcRecord = opts.transform?()
            vcRecord ?= do =>
              [vsModuleName, vsRecordName] = @parseRecordName vsAttr
              @Module::[vsRecordName]
            ipoFacade = Symbol.for 'facade'
            vsCollectionName = "#{inflect.pluralize vsRecordName}Collection"
            voCollection = @collection[ipoFacade].retrieveProxy vsCollectionName
            unless opts.through
              @collection.take "@doc.#{opts.refKey}": @[opts.attr]
                .first()
            else
              # если эту инструкцию упростить до общего вида, то метод belongsTo не будет платформозависим.
              @collection.query
                $forIn: '@doc': "1..1 #{opts.through[1].as} #{@_id} #{voCollection.collectionFullName()}"
                $limit: 1
                $return: '@doc'
              .first()
        @["_#{@name}_props"] ?= {}
        return

    @public @static hasMany: Function,
      default: (typeDefinition, opts={})->
        vsAttr = Object.keys(typeDefinition)[0]
        opts.refKey ?= '_key'
        opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
        opts.get = ->
          vcRecord = opts.transform?()
          vcRecord ?= do =>
            [vsModuleName, vsRecordName] = @parseRecordName vsAttr
            @Module::[vsRecordName]
          ipoFacade = Symbol.for 'facade'
          vsCollectionName = "#{inflect.pluralize vsRecordName}Collection"
          voCollection = @collection[ipoFacade].retrieveProxy vsCollectionName
          unless opts.through
            @collection.take "@doc.#{opts.inverse}": @[opts.refKey]
          else
            # если эту инструкцию упростить до общего вида, то метод hasMany не будет платформозависим.
            @collection.query
              $forIn: '@doc': "1..1 #{opts.through[1].as} #{@_id} #{voCollection.collectionFullName()}"
              $return: '@doc'
        @computed "#{vsAttr}": LeanRC::CursorInterface, opts
        @["_#{@name}_props"] ?= {}
        return

    # не является платформозависимым
    @public @static hasOne: Function,
      default: (typeDefinition, opts={})->
        # TODO: возможно для фильтрации по этому полю, если оно valuable надо как-то зайдествовать customFilters
        vsAttr = Object.keys(typeDefinition)[0]
        opts.refKey ?= '_key'
        opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
        opts.get = ->
          vcRecord = opts.transform?()
          vcRecord ?= do =>
            [vsModuleName, vsRecordName] = @parseRecordName vsAttr
            @Module::[vsRecordName]
          ipoFacade = Symbol.for 'facade'
          vsCollectionName = "#{inflect.pluralize vsRecordName}Collection"
          voCollection = @collection[ipoFacade].retrieveProxy vsCollectionName
          @collection.take "@doc.#{opts.inverse}": @[opts.refKey]
            .first()
        @computed typeDefinition, opts
        @["_#{@name}_props"] ?= {}
        return

    # Cucumber.inverseFor 'tomato' #-> {type: App::Tomato, name: 'cucumbers', kind: 'hasMany'} - в этом ли виде отдавать результат
    @public @static inverseFor: Function,
      default: (asAttrName)->
        vhResult = {}
        # @properties[asAttrName] # что дальше делать пока не понятно
        return vhResult


  return LeanRC::ArangoRelationsMixin.initialize()
