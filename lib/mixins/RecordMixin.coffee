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
        __attrs[AbstractClass.name] ?= do ->
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass["_#{AbstractClass.name}_attrs"] ? {})
        __attrs[AbstractClass.name]

    @public @static edges: Object,
      default: {}
      get: (__edges)->
        AbstractClass = @
        fromSuper = if AbstractClass.__super__?
          AbstractClass.__super__.constructor.edges
        __edges[AbstractClass.name] ?= do ->
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass["_#{AbstractClass.name}_edges"] ? {})
        __edges[AbstractClass.name]

    @public @static computeds: Object,
      default: {}
      get: (__comps)->
        AbstractClass = @
        fromSuper = if AbstractClass.__super__?
          AbstractClass.__super__.constructor.computeds
        __comps[AbstractClass.name] ?= do ->
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass["_#{AbstractClass.name}_comps"] ? {})
        __comps[AbstractClass.name]

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
        @["_#{@name}_attrs"] ?= {}
        @["_#{@name}_edges"] ?= {}
        if @["_#{@name}_attrs"][vsAttr]
          throw new Error "attr `#{vsAttr}` has been defined previously"
        else
          @["_#{@name}_attrs"][vsAttr] = opts
          @["_#{@name}_edges"][vsAttr] = opts if opts.through
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
        @["_#{@name}_comps"] ?= {}
        if @["_#{@name}_comps"][vsAttr]
          throw new Error "comp `#{vsAttr}` has been defined previously"
        else
          @["_#{@name}_comps"][vsAttr] = opts
        @public typeDefinition, opts
        return

    @public @static new: Function,
      default: (aoAttributes, aoCollection)->
        if aoAttributes._type is "#{@moduleName()}::#{@name}"
          @super arguments...
        else
          RecordClass = @findModelByName aoAttributes._type
          RecordClass?.new(aoAttributes, aoCollection) ? @super arguments...

    @public @async save: Function,
      default: ->
        if yield @isNew()
          yield @create()
        else
          yield @update()

    @public @async create: Function,
      default: ->
        unless yield @isNew()
          throw new Error 'Document is exist in collection'
        yield @collection.push @
        return @

    @public @async update: Function,
      default: ->
        if yield @isNew()
          throw new Error 'Document does not exist in collection'
        yield @collection.patch @id, @
        return @

    @public @async delete: Function,
      default: ->
        if yield @isNew()
          throw new Error 'Document is not exist in collection'
        @isHidden = yes
        @updatedAt = new Date()
        yield @save()

    @public @async destroy: Function,
      default: ->
        if yield @isNew()
          throw new Error 'Document is not exist in collection'
        yield @collection.remove @id
        return

    @public @virtual attributes: Function, # метод должен вернуть список атрибутов данного рекорда.
      args: []
      return: Array

    @public clone: Function,
      default: -> @collection.clone @

    @public @async copy: Function,
      default: -> yield @collection.copy @

    @public @async decrement: Function,
      default: (asAttribute, step = 1)->
        unless _.isNumber @[asAttribute]
          throw new Error "doc.attribute `#{asAttribute}` is not Number"
        @[asAttribute] -= step
        yield @save()

    @public @async increment: Function,
      default: (asAttribute, step = 1)->
        unless _.isNumber @[asAttribute]
          throw new Error "doc.attribute `#{asAttribute}` is not Number"
        @[asAttribute] += step
        yield @save()

    @public @async toggle: Function,
      default: (asAttribute)->
        unless _.isBoolean @[asAttribute]
          throw new Error "doc.attribute `#{asAttribute}` is not Boolean"
        @[asAttribute] = not @[asAttribute]
        yield @save()

    @public @async touch: Function,
      default: ->
        @updatedAt = new Date()
        yield @save()

    @public @async updateAttribute: Function,
      default: (name, value)->
        @[name] = value
        yield @save()

    @public @async updateAttributes: Function,
      default: (aoAttributes)->
        for own vsAttrName, voAttrValue of aoAttributes
          do (vsAttrName, voAttrValue)=>
            @[vsAttrName] = voAttrValue
        yield @save()

    @public @async isNew: Function,
      default: ->
        not @id? or not yield @collection.includes @id

    @public @async @virtual reload: Function,
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
      default: (ahPayload)->
        unless ahPayload?
          return null
        vhResult = {}
        for own asAttrName, ahAttrValue of @attributes
          do (asAttrName, {transform} = ahAttrValue)->
            vhResult[asAttrName] = transform().normalize ahPayload[asAttrName]
        @new vhResult

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


  return LeanRC::RecordMixin.initialize()
