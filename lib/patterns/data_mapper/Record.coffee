# по сути здесь надо повторить (что-то скопипастить) код из FoxxMC::Model
# так как все взаимодействие с конкретной платформой (базой)
# должно быть объявлено в конкретном CollectionMixin'е,
# в данном миксине будет платформонезависимый код.

RC = require 'RC'

# так как рекорд будет работать с простыми структурами данных в памяти, он не зависит от платформы.
# если ему надо будет взаимодействовать с платформозависимой логикой - он будет делать это через прокси, но не напрямую (как в эмбере со стором)

module.exports = (LeanRC)->
  class LeanRC::Record extends RC::CoreObject
    @inheritProtected()
    @include RC::ChainsMixin
    @implements LeanRC::RecordInterface

    @Module: LeanRC

    # конструктор принимает второй аргумент, ссылку на коллекцию.
    @public collection: LeanRC::CollectionInterface

    ipoInternalRecord = @private internalRecord: Object # тип и формат хранения надо обдумать. Это инкапсулированные данные последнего сохраненного состояния из базы - нужно для функционала вычисления дельты изменений. (относительно изменений которые проведены над объектом но еще не сохранены в базе данных - хранилище.)


    ############################################################################

    # под вопросом ??????
    # @public @static schema: JoiSchema # это используется в медиаторе на входе и выходе, поэтому это надо объявить там.


    # под вопросом ?????? возможно надо искать через (из) модуля
    @public @static parseModelName: Function, [String], -> Array
    @public @static findModelByName: Function, [String], -> Array
    @public findModelByName: Function, [String], -> Array
    @public parseModelName: Function, [String], -> Array



    # здесь не декларируются before/after хуки, потому что их использование относится сугубо к реализации, но не к спецификации интерфейса как такового.



    # под вопросом ??????
    @public updateEdges: Function, [ANY], -> ANY # any type



    # под вопросом ?????? # возможно надо это определять в сериалайзере
    @public getSnapshot: Function, [], -> Object
    @private _forClient: Function, [Object], -> Object
    @public @static serializableAttributes: Function, [], -> Object
    @public @static serializeFromBatch: Function, [Object], -> Object
    @public @static serializeFromClient: Function, [Object], -> Object
    @public serializeForClient: Function, [Object], -> Object


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
      default: (name, schema, opts={})->
        {valuable, sortable, groupable, filterable} = opts
        @["_#{@name}_attrs"] ?= {}
        @["_#{@name}_edges"] ?= {}
        unless @["_#{@name}_attrs"][name]
          @["_#{@name}_attrs"][name] = schema
          @["_#{@name}_edges"][name] = opts if opts.through
        else
          throw new Error "attr `#{name}` has been defined previously"
        return

    @public @static computed: Function,
      default: ->
        @comp arguments...
        return

    @public @static comp: Function,
      default: (name, opts, lambda)->
        {type, model, valuable, valuableAs} = opts
        model ?= inflect.singularize inflect.underscore name
        if not lambda? or not type?
          return throw new Error '`lambda` and `type` options is required'
        if valuable?
          schema = =>
            unless model in SIMPLE_TYPES
              [ModelClass, vModel] = @findModelByName model
            else
              vModel = model
            return if vModel in ['string', 'boolean', 'number']
              joi[vModel]().empty(null).optional()
            else if vModel is 'date'
              joi.string().empty(null).optional()
            else if type is 'item' and vModel is 'object'
              joi.object().empty(null).optional()
            else if type is 'array' and vModel is 'object'
              joi.array().items joi.object().empty(null).optional()
            else if type is 'item' and not /.*[.].*/.test valuable
              ModelClass.schema()
            else if type is 'item' and /.*[.].*/.test valuable
              [..., prop_name] = valuable.split '.'
              ModelClass.attributes()[prop_name]
            else if type is 'array' and not /.*[.].*/.test valuable
              joi.array().items ModelClass.schema()
            else if type is 'array' and /.*[.].*/.test valuable
              [..., prop_name] = valuable.split '.'
              joi.array().items ModelClass.attributes()[prop_name]
        else
          schema = -> {}
        opts.schema ?= schema
        @["_#{@name}_comps"] ?= {}
        unless @["_#{@name}_comps"][name]
          @["_#{@name}_comps"][name] = opts
          empty_result = switch type
            when 'item'
              null
            when 'array'
              []
            else
              throw new Error 'type must be `item` or `array` only'
          @defineProperty name,
            get: ->
              result = @["__#{name}"]
              result ?= @["__#{name}"] = lambda.apply(@, []) ? empty_result
              result
        else
          throw new Error "comp `#{name}` has been defined previously"
        return

    @public @static new: Function,
      default: (aoAttributes, aoCollection)->
        if aoAttributes._type is "#{@moduleName()}::#{@name}"
          @super arguments...
        else
          [ModelClass] = @findModelByName aoAttributes._type
          ModelClass?.new(aoAttributes, aoCollection) ? @super arguments...

    # может заиспользовать для объявления joi схем для атрибутов. Чтобы объявления атрибутов разгрузить немного.
    @public @static validate: Function, # что внутри делать пока не понятно.
      default: (attribute, options)->
        return

    @public _key: String
    @public _rev: String
    @public _type: String
    @public isHidden: Boolean, {default: no}
    @public createdAt: Date
    @public updatedAt: Date

    # если мы здесь не добавляем конкретный RelationsMixin в котором есть имлементация метода @prop - то как объявить эти атрибуты?
    # или как решение - выпилить эти повторения из рекорда вообще.?
    @public id: String
    @public rev: String
    @public type: String

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
        # надо ли использовать @collection.create или другой метод ???

    # @public beforeCreate: Function, [], -> NILL
    # @public afterCreate: Function, [ANY], -> ANY # any type
    @public update: Function, [], -> RecordInterface
    # @public beforeUpdate: Function, [], -> NILL
    # @public afterUpdate: Function, [ANY], -> ANY # any type
    @public delete: Function,
      default: ->
        if @isNew()
          throw new Error 'Document is not exist in collection'
    # @public beforeDelete: Function, [], -> NILL
    # @public afterDelete: Function, [ANY], -> ANY # any type
    @public destroy: Function,
      default: ->
        if @isNew()
          throw new Error 'Document is not exist in collection'
    # @public beforeDestroy: Function, [], -> NILL
    # @public afterDestroy: Function, [], -> NILL

    @public @virtual attributes: Function, # метод должен вернуть список атрибутов данного рекорда.
      args: []
      return: Array

    @public clone: Function,
      default: -> @

    @public copy: Function,
      default: -> @

    @public deepCopy: Function,
      default: -> @

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
