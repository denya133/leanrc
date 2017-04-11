_ = require 'lodash'
joi = require 'joi'
inflect = do require 'i'

RC = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::RecordMixin extends RC::Mixin
    @inheritProtected()

    @Module: LeanRC

    # конструктор принимает второй аргумент, ссылку на коллекцию.
    @public collection: LeanRC::CollectionInterface

    ipoInternalRecord = @private internalRecord: Object # тип и формат хранения надо обдумать. Это инкапсулированные данные последнего сохраненного состояния из базы - нужно для функционала вычисления дельты изменений. (относительно изменений которые проведены над объектом но еще не сохранены в базе данных - хранилище.)
    cphAttributes = @protected @static attributesPointer: Symbol,
      get: -> Symbol.for "attributes_#{@moduleName()}_#{@name}"
    cphComputeds  = @protected @static computedsPointer: Symbol,
      get: -> Symbol.for "computeds_#{@moduleName()}_#{@name}"
    cphEdges      = @protected @static edgesPointer: Symbol,
      get: -> Symbol.for "edges_#{@moduleName()}_#{@name}"
    cphRelations  = @protected @static relationsPointer: Symbol,
      get: -> Symbol.for "relations_#{@moduleName()}_#{@name}"

    @public @static schema: Object,
      default: {}
      get: (_data)->
        _data[@name] ?= do =>
          vhAttrs = {}
          for own asAttrName, ahAttrValue of @attributes
            do (asAttrName, ahAttrValue)=>
              vhAttrs[asAttrName] = ahAttrValue.validate
          joi.object vhAttrs
        _data[@name]

    @public @static parseRecordName: Function,
      default: (asName)->
        if /.*[:][:].*/.test(asName)
          [vsModuleName, vsModel] = asName.split '::'
        else
          [vsModuleName, vsModel] = [@moduleName(), inflect.camelize inflect.underscore asName]
        [vsModuleName, vsModel]

    @public parseRecordName: Function,
      default: -> @constructor.parseRecordName arguments...


    ############################################################################

    # # под вопросом ?????? возможно надо искать через (из) модуля
    # @public @static findModelByName: Function, [String], -> Array
    # @public findModelByName: Function, [String], -> Array

    # # под вопросом ??????
    # @public updateEdges: Function, [ANY], -> ANY # any type

    ############################################################################


    @public @static parentClassNames: Function,
      default: (AbstractClass = null)->
        AbstractClass ?= @
        fromSuper = if AbstractClass.__super__?
          @parentClassNames AbstractClass.__super__.constructor
        _.uniq [].concat(fromSuper ? [])
          .concat [AbstractClass.name]

    @public @static attributes: Object,
      default: {}
      get: (__attrs)->
        AbstractClass = @
        fromSuper = if AbstractClass.__super__?
          AbstractClass.__super__.constructor.attributes
        __attrs[AbstractClass[cphAttributes]] ?= do ->
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass[AbstractClass[cphAttributes]] ? {})
        __attrs[AbstractClass[cphAttributes]]

    @public @static edges: Object,
      default: {}
      get: (__edges)->
        AbstractClass = @
        fromSuper = if AbstractClass.__super__?
          AbstractClass.__super__.constructor.edges
        __edges[AbstractClass[cphEdges]] ?= do ->
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass[AbstractClass[cphEdges]] ? {})
        __edges[AbstractClass[cphEdges]]

    @public @static computeds: Object,
      default: {}
      get: (__comps)->
        AbstractClass = @
        fromSuper = if AbstractClass.__super__?
          AbstractClass.__super__.constructor.computeds
        __comps[AbstractClass[cphComputeds]] ?= do ->
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass[AbstractClass[cphComputeds]] ? {})
        __comps[AbstractClass[cphComputeds]]

    @public @static attribute: Function,
      default: ->
        @attr arguments...
        return

    @public @static attr: Function,
      default: (typeDefinition, opts={})->
        vsAttr = Object.keys(typeDefinition)[0]
        vcAttrType = typeDefinition[vsAttr]
        opts.transform ?= switch vcAttrType
          when String, Date, Number, Boolean
            -> LeanRC::["#{vcAttrType.name}Transform"]
          else
            -> LeanRC::Transform
        opts.validate ?= switch vcAttrType
          when String, Date, Number, Boolean
            -> joi[inflect.underscore vcAttrType.name]()
          else
            -> joi.object()
        {set} = opts
        opts.set = (aoData)->
          {value:voData} = opts.validate().validate aoData
          if _.isFunction set
            set.apply @, [voData]
          else
            voData
        @[@[cphAttributes]] ?= {}
        @[@[cphEdges]] ?= {}
        if @[@[cphAttributes]][vsAttr]
          throw new Error "attr `#{vsAttr}` has been defined previously"
        else
          @[@[cphAttributes]][vsAttr] = opts
          @[@[cphEdges]][vsAttr] = opts if opts.through
        @public typeDefinition, opts
        return

    @public @static computed: Function,
      default: ->
        @comp arguments...
        return

    @public @static comp: Function,
      default: (typeDefinition, opts)->
        vsAttr = Object.keys(typeDefinition)[0]
        unless opts.get?
          return throw new Error '`lambda` options is required'
        @[@[cphComputeds]] ?= {}
        if @[@[cphComputeds]][vsAttr]
          throw new Error "comp `#{vsAttr}` has been defined previously"
        else
          @[@[cphComputeds]][vsAttr] = opts
        @public typeDefinition, opts
        return

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
            vcRecord = opts.transform()
            vsCollectionName = "#{inflect.pluralize vcRecord.name}Collection"
            voCollection = @collection.facade.retrieveProxy vsCollectionName
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
          vcRecord = opts.transform()
          vsCollectionName = "#{inflect.pluralize vcRecord.name}Collection"
          voCollection = @collection.facade.retrieveProxy vsCollectionName
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
          vcRecord = opts.transform()
          vsCollectionName = "#{inflect.pluralize vcRecord.name}Collection"
          voCollection = @collection.facade.retrieveProxy vsCollectionName
          @collection.take "@doc.#{opts.inverse}": @[opts.refKey]
            .first()
        @computed typeDefinition, opts
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

    @public @static new: Function,
      default: (aoAttributes, aoCollection)->
        if '_type' of (aoAttributes ? {})
          if aoAttributes._type is "#{@moduleName()}::#{@name}"
            @super arguments...
          else
            RecordClass = @findModelByName aoAttributes._type
            RecordClass?.new(aoAttributes, aoCollection) ? @super arguments...
        else
          @super arguments...

    @public save: Function,
      default: ->
        if @isNew()
          @create()
        else
          @update()

    @public create: Function,
      default: ->
        unless @isNew()
          throw new Error 'Document is exist in collection'
        @collection.push @
        vhAttributes = {}
        for own key of @constructor.attributes
          vhAttributes[key] = @[key]
        @[ipoInternalRecord] = vhAttributes
        return @

    @public update: Function,
      default: ->
        if @isNew()
          throw new Error 'Document does not exist in collection'
        @collection.patch {'@doc._key': $eq: @id}, @
        vhAttributes = {}
        for own key of @constructor.attributes
          vhAttributes[key] = @[key]
        @[ipoInternalRecord] = vhAttributes
        return @

    @public delete: Function,
      default: ->
        if @isNew()
          throw new Error 'Document is not exist in collection'
        @isHidden = yes
        @updatedAt = new Date()
        @save()

    @public destroy: Function,
      default: ->
        if @isNew()
          throw new Error 'Document is not exist in collection'
        @collection.remove '@doc._key': $eq: @id
        return

    @public @virtual attributes: Function, # метод должен вернуть список атрибутов данного рекорда.
      args: []
      return: Array

    @public clone: Function,
      default: -> @collection.clone @

    @public copy: Function,
      default: -> @collection.copy @

    @public decrement: Function,
      default: (asAttribute, step = 1)->
        unless _.isNumber @[asAttribute]
          throw new Error "doc.attribute `#{asAttribute}` is not Number"
        @[asAttribute] -= step
        @save()

    @public increment: Function,
      default: (asAttribute, step = 1)->
        unless _.isNumber @[asAttribute]
          throw new Error "doc.attribute `#{asAttribute}` is not Number"
        @[asAttribute] += step
        @save()

    @public toggle: Function,
      default: (asAttribute)->
        unless _.isBoolean @[asAttribute]
          throw new Error "doc.attribute `#{asAttribute}` is not Boolean"
        @[asAttribute] = not @[asAttribute]
        @save()

    @public touch: Function,
      default: ->
        @updatedAt = new Date()
        @save()

    @public updateAttribute: Function,
      default: (name, value)->
        @[name] = value
        @save()

    @public updateAttributes: Function,
      default: (aoAttributes)->
        for own vsAttrName, voAttrValue of aoAttributes
          do (vsAttrName, voAttrValue)=>
            @[vsAttrName] = voAttrValue
        @save()

    @public isNew: Function,
      default: ->
        not @id? or not @collection.includes @id

    @public @virtual reload: Function,
      args: []
      return: LeanRC::RecordInterface

    # TODO: не учтены установки значений, которые раньше не были установлены
    @public changedAttributes: Function,
      default: ->
        vhResult = {}
        for own vsAttrName, voAttrValue of @[ipoInternalRecord]
          do (vsAttrName, voAttrValue)=>
            if @[vsAttrName] isnt voAttrValue
              vhResult[vsAttrName] = [voAttrValue, @[vsAttrName]]
        vhResult

    @public resetAttribute: Function,
      default: (asAttribute)->
        @[asAttribute] = @[ipoInternalRecord][asAttribute]
        return

    @public rollbackAttributes: Function,
      default: ->
        for own vsAttrName, voAttrValue of @[ipoInternalRecord]
          do (vsAttrName, voAttrValue)=>
            @[vsAttrName] = voAttrValue
        return


    @public @static normalize: Function,
      default: (ahPayload, aoCollection)->
        unless ahPayload?
          return null
        vhResult = {}
        for own asAttrName, ahAttrValue of @attributes
          do (asAttrName, {transform} = ahAttrValue)->
            vhResult[asAttrName] = transform().normalize ahPayload[asAttrName]
        result = @new vhResult, aoCollection
        vhAttributes = {}
        for own key of @attributes
          vhAttributes[key] = result[key]
        result[ipoInternalRecord] = vhAttributes
        result

    @public @static serialize:   Function,
      default: (aoRecord)->
        unless aoRecord?
          return null
        vhResult = {}
        for own asAttrName, ahAttrValue of @attributes
          do (asAttrName, {transform} = ahAttrValue)->
            vhResult[asAttrName] = transform().serialize aoRecord[asAttrName]
        vhResult


    constructor: (aoProperties, aoCollection) ->
      super arguments...
      console.log 'Init of Record', @constructor.name, aoProperties
      @collection = aoCollection

      # TODO: надо не забыть про internalRecord
      for own vsAttrName, voAttrValue of aoProperties
        do (vsAttrName, voAttrValue)=>
          @[vsAttrName] = voAttrValue

      console.log 'dfdfdf 666'

    @public @static initialize: Function,
      default: (args...) ->
        @super args...
        vlKeys = Reflect.ownKeys @
        for key in vlKeys
          switch key.toString()
            when 'Symbol(_attributes)'
              @[key]?[@[cphAttributes]] = null
            when 'Symbol(_edges)'
              @[key]?[@[cphEdges]] = null
            when 'Symbol(_computeds)'
              @[key]?[@[cphEdges]] = null
            when 'Symbol(_relations)'
              @[key]?[@[cphRelations]] = null
        return


  return LeanRC::RecordMixin.initialize()
