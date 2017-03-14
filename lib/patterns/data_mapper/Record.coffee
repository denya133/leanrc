# по сути здесь надо повторить (что-то скопипастить) код из FoxxMC::Model
# так как все взаимодействие с конкретной платформой (базой)
# должно быть объявлено в конкретном CollectionMixin'е,
# в данном миксине будет платформонезависимый код.

RC = require 'RC'

# так как рекорд будет работать с простыми структурами данных в памяти, он не зависит от платформы.
# если ему надо будет взаимодействовать с платформозависимой логикой - он будет делать это через прокси, но не напрямую (как в эмбере со стором)

###
```coffee
class App::TomatoRecord extends LeanRC::Record
  @inheritProtected()
  @include RC::ChainsMixin
  @include LeanRC::ArangoRelationsMixin

  @Module: App

  @attr title: String,
    # возможно есть смысл объявить опшен в RC::CoreObject.public - чтобы при установке в сеттере проходила валидация
    validate: -> joi.string() # !!! нужен для сложной валидации данных
    # transform указывать не надо, т.к. стандартный тип, LeanRC::StringTransform

  @attr nameObj: App::NameObj,
    validate: -> joi.object().required().start().end().default({})
    transform: -> App::NameObjTransform # or some record class App::OnionRecord

  @attr description: String

  @attr registeredAt: Date,
    validate: -> joi.date()
    transform: -> App::MyDateTransform
```
###

module.exports = (LeanRC)->
  class LeanRC::Record extends RC::CoreObject
    @inheritProtected()
    @include RC::ChainsMixin
    @implements LeanRC::RecordInterface

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



    # здесь не декларируются before/after хуки, потому что их использование относится сугубо к реализации, но не к спецификации интерфейса как такового.



    # # под вопросом ??????
    # @public updateEdges: Function, [ANY], -> ANY # any type



    # # под вопросом ?????? # возможно надо это определять в сериалайзере
    # @public getSnapshot: Function, [], -> Object
    # @private _forClient: Function, [Object], -> Object
    # @public @static serializableAttributes: Function, [], -> Object
    # @public @static serializeFromBatch: Function, [Object], -> Object
    # @public @static serializeFromClient: Function, [Object], -> Object
    # @public serializeForClient: Function, [Object], -> Object


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
        unless @["_#{@name}_attrs"][vsAttr]
          @["_#{@name}_attrs"][vsAttr] = opts
          @["_#{@name}_edges"][vsAttr] = opts if opts.through
        else
          throw new Error "attr `#{vsAttr}` has been defined previously"
        @public typeDefinition, opts
        return

    @public @static computed: Function,
      default: ->
        @comp arguments...
        return

    @public @static comp: Function,
      default: (typeDefinition, opts)->
        vsAttr = Object.keys(typeDefinition)[0]
        vcAttrType = typeDefinition[vsAttr]
        {model, valuable, valuableAs, get} = opts
        model ?= inflect.singularize inflect.underscore vsAttr
        unless opts.get?
          return throw new Error '`lambda` options is required'
        if valuable?
          validate = =>
            unless model in SIMPLE_TYPES
              RecordClass = @findModelByName model
            return if model in ['string', 'boolean', 'number']
              joi[model]().empty(null).optional()
            else if model is 'date'
              joi.string().empty(null).optional()
            else if vcAttrType isnt Array and model is 'object'
              joi.object().empty(null).optional()
            else if vcAttrType is Array and model is 'object'
              joi.array().items joi.object().empty(null).optional()
            else if vcAttrType isnt Array and not /.*[.].*/.test valuable
              RecordClass.schema()
            else if vcAttrType isnt Array and /.*[.].*/.test valuable
              [..., prop_name] = valuable.split '.'
              RecordClass.attributes[prop_name].validate
            else if vcAttrType is Array and not /.*[.].*/.test valuable
              joi.array().items RecordClass.schema()
            else if vcAttrType is Array and /.*[.].*/.test valuable
              [..., prop_name] = valuable.split '.'
              joi.array().items RecordClass.attributes[prop_name].validate
        else
          validate = -> {}
        opts.validate ?= validate
        @["_#{@name}_comps"] ?= {}
        unless @["_#{@name}_comps"][vsAttr]
          @["_#{@name}_comps"][vsAttr] = opts
        else
          throw new Error "comp `#{vsAttr}` has been defined previously"
        @public typeDefinition, opts
        return

    @public @static new: Function,
      default: (aoAttributes, aoCollection)->
        if aoAttributes._type is "#{@moduleName()}::#{@name}"
          @super arguments...
        else
          RecordClass = @findModelByName aoAttributes._type
          RecordClass?.new(aoAttributes, aoCollection) ? @super arguments...


    @attribute _key: String
    @attribute _rev: String
    @attribute _type: String
    @attribute isHidden: Boolean, {default: no}
    @attribute createdAt: Date
    @attribute updatedAt: Date

    # если мы здесь не добавляем конкретный RelationsMixin в котором есть имлементация метода @prop - то как объявить эти атрибуты?
    # или как решение - выпилить эти повторения из рекорда вообще.?
    @computed id: String, {valuable: 'id', get: -> @_key}
    @computed rev: String, {valuable: 'rev', get: -> @_rev}
    @computed type: String, {valuable: 'type', get: -> @_type}

    @chains ['validate', 'save', 'create', 'update', 'delete', 'destroy']

    @beforeHook 'beforeValidate', only: ['validate']
    @afterHook 'afterValidate', only: ['validate']

    @beforeHook 'beforeSave', only: ['save']
    @beforeHook 'beforeCreate', only: ['create']
    @beforeHook 'beforeUpdate', only: ['update']

    @afterHook 'afterUpdate', only: ['update']
    @afterHook 'afterCreate', only: ['create']
    @afterHook 'afterSave', only: ['save']

    @beforeHook 'beforeDelete', only: ['delete']
    @afterHook 'afterDelete', only: ['delete']

    # под вопросом ???????????????
    # @afterHook 'updateEdges', only: ['create', 'update', 'delete']

    @beforeHook 'beforeDestroy', only: ['destroy']
    @afterHook 'afterDestroy', only: ['destroy']

    # под вопросом??? т.к. не знаю как лучше: вызывать валидацию рекорда целиком, или вызывать валидацию при установке (изменении) каждого атрибута по отдельности
    @public validate: Function, [], -> RecordInterface
    # @public beforeValidate: Function, [], -> NILL
    # @public afterValidate: Function, [], -> NILL

    @public save: Function,
      default: ->
        @validate()
        if @isNew()
          @create()
        else
          @update()

    # @public beforeSave: Function, [], -> NILL
    # @public afterSave: Function, [ANY], -> ANY # any type
    @public create: Function,
      default: ->
        unless @isNew()
          throw new Error 'Document is exist in collection'
        @collection.push @
        return @

    # @public beforeCreate: Function, [], -> NILL
    # @public afterCreate: Function, [ANY], -> ANY # any type
    @public update: Function,
      default: ->
        if @isNew()
          throw new Error 'Document does not exist in collection'
        @collection.patch {'@doc._key': $eq: @id}, @
        return @

    # @public beforeUpdate: Function, [], -> NILL
    # @public afterUpdate: Function, [ANY], -> ANY # any type

    @public delete: Function,
      default: ->
        if @isNew()
          throw new Error 'Document is not exist in collection'
        @isHidden = yes
        @updatedAt = new Date()
        @save()

    # @public beforeDelete: Function, [], -> NILL
    # @public afterDelete: Function, [ANY], -> ANY # any type

    @public destroy: Function,
      default: ->
        if @isNew()
          throw new Error 'Document is not exist in collection'
        @collection.remove '@doc._key': $eq: @id
        return

    # @public beforeDestroy: Function, [], -> NILL
    # @public afterDestroy: Function, [], -> NILL

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


  return LeanRC::Record.initialize()
