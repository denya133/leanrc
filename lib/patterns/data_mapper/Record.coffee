

###
```coffee
module.exports = (Module)->
  Module.defineMixin Module::Record, (BaseClass) ->
    class TomatoEntryMixin extends BaseClass
      @inheritProtected()

      # Place for attributes and computeds definitions
      @attribute title: String,
        validate: -> joi.string() # !!! нужен для сложной валидации данных
        # transform указывать не надо, т.к. стандартный тип, Module::StringTransform

      @attribute nameObj: Module::NameObj,
        validate: -> joi.object().required().start().end().default({})
        transform: -> Module::NameObjTransform # or some record class Module::OnionRecord

      @attribute description: String

      @attribute registeredAt: Date,
        validate: -> joi.date().iso()
        transform: -> Module::MyDateTransform
    TomatoEntryMixin.initializeMixin()
```

```coffee
module.exports = (Module)->
  {
    Record
    TomatoEntryMixin
  } = Module::

  class TomatoRecord extends Record
    @inheritProtected()
    @include TomatoEntryMixin
    @module Module

    # business logic and before-, after- colbacks

  TomatoRecord.initialize()
```
###


module.exports = (Module)->
  {
    AnyT, NilT, PointerT, JoiT
    PropertyDefinitionT, AttributeOptionsT, ComputedOptionsT
    AttributeConfigT, ComputedConfigT
    FuncG, TupleG, MaybeG, SubsetG, DictG, ListG
    RecordInterface, CollectionInterface
    CoreObject
    ChainsMixin
    Utils: { _, inflect, joi }
  } = Module::

  class Record extends CoreObject
    @inheritProtected()
    @implements RecordInterface
    @include ChainsMixin
    @module Module

    ipoInternalRecord = PointerT @protected internalRecord: Object
    ipoSchemas = PointerT @protected @static schemas: DictG(String, JoiT),
      default: {}

    @public collection: CollectionInterface

    @public @static schema: JoiT,
      get: ->
        @[ipoSchemas][@name] ?= do =>
          vhAttrs = {}
          for own asAttr, ahValue of @attributes
            vhAttrs[asAttr] = do (asAttr, ahValue)=>
              if _.isFunction ahValue.validate
                ahValue.validate.call(@)
              else
                ahValue.validate

          for own asAttr, ahValue of @computeds
            vhAttrs[asAttr] = do (asAttr, ahValue)=>
              if _.isFunction ahValue.validate
                ahValue.validate.call(@)
              else
                ahValue.validate
          joi.object vhAttrs
        @[ipoSchemas][@name]

    @public @static @async normalize: FuncG([MaybeG(Object), CollectionInterface], RecordInterface),
      default: (ahPayload, aoCollection)->
        unless ahPayload?
          return null
        vhAttributes = {}

        unless ahPayload.type?
          throw new Error "Attribute `type` is required and format '<ModuleName>::<RecordClassName>'"

        RecordClass = if @name is ahPayload.type.split('::')[1]
          @
        else
          @findRecordByName ahPayload.type

        for own asAttr, { transform } of RecordClass.attributes
          vhAttributes[asAttr] = yield transform.call(RecordClass).normalize ahPayload[asAttr]

        vhAttributes.type = ahPayload.type
        # NOTE: vhAttributes processed before new - it for StateMachine in record (when it has)

        voRecord = RecordClass.new vhAttributes, aoCollection

        voRecord[ipoInternalRecord] = voRecord.constructor.makeSnapshot voRecord
        yield return voRecord

    @public @static @async serialize: FuncG([MaybeG RecordInterface], MaybeG Object),
      default: (aoRecord)->
        unless aoRecord?
          return null

        unless aoRecord.type?
          throw new Error "Attribute `type` is required and format '<ModuleName>::<RecordClassName>'"

        vhResult = {}
        for own asAttr, { transform } of aoRecord.constructor.attributes
          vhResult[asAttr] = yield transform.call(@).serialize aoRecord[asAttr]
        yield return vhResult

    @public @static @async recoverize: FuncG([MaybeG(Object), CollectionInterface], MaybeG RecordInterface),
      default: (ahPayload, aoCollection)->
        unless ahPayload?
          return null
        vhAttributes = {}

        unless ahPayload.type?
          throw new Error "Attribute `type` is required and format '<ModuleName>::<RecordClassName>'"

        RecordClass = if @name is ahPayload.type.split('::')[1]
          @
        else
          @findRecordByName ahPayload.type

        for own asAttr, { transform } of RecordClass.attributes when asAttr of ahPayload
          vhAttributes[asAttr] = yield transform.call(RecordClass).normalize ahPayload[asAttr]

        vhAttributes.type = ahPayload.type
        # NOTE: vhAttributes processed before new - it for StateMachine in record (when it has)

        voRecord = RecordClass.new vhAttributes, aoCollection

        yield return voRecord

    @public @static objectize: FuncG([MaybeG RecordInterface], MaybeG Object),
      default: (aoRecord)->
        unless aoRecord?
          return null

        unless aoRecord.type?
          throw new Error "Attribute `type` is required and format '<ModuleName>::<RecordClassName>'"

        vhResult = {}

        for own asAttr, { transform } of aoRecord.constructor.attributes
          vhResult[asAttr] = transform.call(@).objectize aoRecord[asAttr]
        for own asAttr, { transform } of aoRecord.constructor.computeds
          vhResult[asAttr] = transform.call(@).objectize aoRecord[asAttr]
        return vhResult

    @public @static makeSnapshot: FuncG([MaybeG RecordInterface], MaybeG Object),
      default: (aoRecord)->
        unless aoRecord?
          return null

        unless aoRecord.type?
          throw new Error "Attribute `type` is required and format '<ModuleName>::<RecordClassName>'"

        vhResult = {}

        for own asAttr, { transform } of aoRecord.constructor.attributes
          vhResult[asAttr] = transform.call(@).objectize aoRecord[asAttr]
        vhResult

    @public @static parseRecordName: FuncG(String, TupleG String, String),
      default: (asName)->
        if /.*[:][:].*/.test(asName)
          [vsModuleName, vsRecordName] = asName.split '::'
        else
          [vsModuleName, vsRecordName] = [@moduleName(), inflect.camelize inflect.underscore inflect.singularize asName]
        unless /(Record$)|(Migration$)/.test vsRecordName
          vsRecordName += 'Record'
        [vsModuleName, vsRecordName]

    @public parseRecordName: FuncG(String, TupleG String, String),
      default: (args...)-> @constructor.parseRecordName args...

    @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
      default: (asName)->
        [vsModuleName, vsRecordName] = @parseRecordName asName
        (@Module.NS ? @Module::)[vsRecordName] ? @

    @public findRecordByName: FuncG(String, SubsetG RecordInterface),
      default: (asName)-> @constructor.findRecordByName asName

    ###
      @customFilter ->
        reason:
          '$eq': (value)->
            # string of some aql code for example
          '$neq': (value)->
            # string of some aql code for example
    ###
    @public @static customFilters: Object,
      get: -> @metaObject.getGroup 'customFilters', no

    @public @static customFilter: FuncG(Function, NilT),
      default: (amStatementFunc)->
        config = amStatementFunc.call @
        for own asFilterName, aoStatement of config
          @metaObject.addMetaData 'customFilters', asFilterName, aoStatement
        return

    @public @static parentClassNames: FuncG([MaybeG SubsetG RecordInterface], ListG String),
      default: (AbstractClass = null)->
        AbstractClass ?= @
        SuperClass = Reflect.getPrototypeOf AbstractClass
        fromSuper = unless _.isEmpty SuperClass?.name
          @parentClassNames SuperClass
        _.uniq [].concat(fromSuper ? [])
          .concat [AbstractClass.name]

    @public @static attributes: DictG(String, AttributeConfigT),
      get: -> @metaObject.getGroup 'attributes', no
    @public @static computeds: DictG(String, ComputedConfigT),
      get: -> @metaObject.getGroup 'computeds', no

    @public @static attribute: FuncG([PropertyDefinitionT, AttributeOptionsT], NilT),
      default: ->
        @attr arguments...
        return

    @public @static attr: FuncG([PropertyDefinitionT, AttributeOptionsT], NilT),
      default: (typeDefinition, opts={})->
        [vsAttr] = Object.keys typeDefinition
        vcAttrType = typeDefinition[vsAttr]
        # NOTE: это всего лишь автоматическое применение трансформа, если он не указан явно. здесь НЕ надо автоматически подставить нужный рекорд или кастомный трансформ - они если должны использоваться, должны быть указаны вручную в схеме рекорда программистом.
        opts.transform ?= switch vcAttrType
          when String, Date, Number, Boolean, Array, Object
            -> Module::["#{vcAttrType.name}Transform"]
          else
            -> Module::Transform
        opts.validate ?= -> opts.transform.call(@).schema
        {set} = opts
        opts.set = (aoData)->
          {value:voData} = opts.validate.call(@).validate aoData
          if _.isFunction set
            set.apply @, [voData]
          else
            voData
        if @attributes[vsAttr]?
          throw new Error "attribute `#{vsAttr}` has been defined previously"
        else
          @metaObject.addMetaData 'attributes', vsAttr, opts
        @public typeDefinition, opts
        return

    @public @static computed: FuncG([PropertyDefinitionT, ComputedOptionsT], NilT),
      default: ->
        @comp arguments...
        return

    # NOTE: изначальная задумка была в том, чтобы определять вычисляемые значения - НЕ ПРОМИСЫ! (т.е. некоторое значение, которое отправляется в респонзе реально не хранится в базе, но вычисляется НЕ асинхронной функцией-гетером)
    @public @static comp: FuncG([PropertyDefinitionT, ComputedOptionsT], NilT),
      default: (typeDefinition, opts)->
        # [typeDefinition, ..., opts] = args
        # if typeDefinition is opts
        #   typeDefinition = "#{opts.attr}": opts.attrType
        [vsAttr] = Object.keys typeDefinition
        vcAttrType = typeDefinition[vsAttr]
        # NOTE: это всего лишь автоматическое применение трансформа, если он не указан явно. здесь не надо автоматически подставить нужный рекорд или кастомный трансформ - они если должны использоваться, должны быть указаны вручную в схеме рекорда программистом.
        opts.transform ?= switch vcAttrType
          when String, Date, Number, Boolean, Array, Object
            -> Module::["#{vcAttrType.name}Transform"]
          else
            -> Module::Transform
        opts.validate ?= -> opts.transform.call(@).schema.strip()
        unless opts.get?
          throw new Error 'getter `lambda` options is required'
        if opts.set?
          throw new Error 'setter `lambda` options is forbidden'
        if @computeds[vsAttr]?
          throw new Error "computed `#{vsAttr}` has been defined previously"
        else
          @metaObject.addMetaData 'computeds', vsAttr, opts
        @public typeDefinition, opts
        return

    @public @static new: FuncG([Object, CollectionInterface], RecordInterface),
      default: (aoAttributes, aoCollection)->
        aoAttributes ?= {}

        unless aoAttributes.type?
          throw new Error "Attribute `type` is required and format '<ModuleName>::<RecordClassName>'"
        if @name is aoAttributes.type.split('::')[1]
          @super aoAttributes, aoCollection
        else
          RecordClass = @findRecordByName aoAttributes.type
          if RecordClass is @
            @super aoAttributes, aoCollection
          else
            RecordClass.new(aoAttributes, aoCollection)

    @public @async save: FuncG([], RecordInterface),
      default: ->
        result = if yield @isNew()
          yield @create()
        else
          yield @update()
        return result

    @public @async create: FuncG([], RecordInterface),
      default: ->
        response = yield @collection.push @
        if response?
          # { id } = response
          # @id ?= id if id
          for own asAttr of @constructor.attributes
            @[asAttr] = response[asAttr]
          @[ipoInternalRecord] = response[ipoInternalRecord]
        yield return @

    @public @async update: FuncG([], RecordInterface),
      default: ->
        response = yield @collection.override @id, @
        if response?
          for own asAttr of @constructor.attributes
            @[asAttr] = response[asAttr]
          @[ipoInternalRecord] = response[ipoInternalRecord]
        yield return @

    @public @async delete: FuncG([], RecordInterface),
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

    @attribute id: String
    @attribute rev: String
    @attribute type: String
    @attribute isHidden: Boolean,
      validate: -> joi.boolean().empty(null).default(no, 'false by default')
      default: no
    @attribute createdAt: Date
    @attribute updatedAt: Date
    @attribute deletedAt: Date

    @chains ['create', 'update', 'delete', 'destroy']

    @beforeHook 'beforeUpdate', only: ['update']
    @beforeHook 'beforeCreate', only: ['create']

    @afterHook 'afterUpdate', only: ['update']
    @afterHook 'afterCreate', only: ['create']

    @beforeHook 'beforeDelete', only: ['delete']
    @afterHook 'afterDelete', only: ['delete']

    @afterHook 'afterDestroy', only: ['destroy']

    @public @async afterCreate: FuncG(RecordInterface, RecordInterface),
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'createdRecord', aoRecord
        yield return @

    @public @async beforeUpdate: Function,
      default: ->
        @updatedAt = new Date()
        yield return

    @public @async beforeCreate: Function,
      default: ->
        @id ?= yield @collection.generateId()
        now = new Date()
        @createdAt ?= now
        @updatedAt ?= now
        yield return

    @public @async afterUpdate: FuncG(RecordInterface, RecordInterface),
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'updatedRecord', aoRecord
        yield return @

    @public beforeDelete: Function,
      default: ->
        @isHidden = yes
        now = new Date()
        @updatedAt = now
        @deletedAt = now
        return

    @public afterDelete: FuncG(RecordInterface, RecordInterface),
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'deletedRecord', aoRecord
        return @

    @public afterDestroy: FuncG(RecordInterface, NilT),
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'destroyedRecord', aoRecord
        return

    # NOTE: метод должен вернуть список атрибутов данного рекорда.
    @public attributes: FuncG([], Object),
      default: -> Object.keys @constructor.attributes

    # NOTE: в оперативной памяти создается клон рекорда, НО с другим id
    @public @async clone: FuncG([], RecordInterface),
      default: -> yield @collection.clone @

    # NOTE: в коллекции создается копия рекорда, НО с другим id
    @public @async copy: FuncG([], RecordInterface),
      default: -> yield @collection.copy @

    @public @async decrement: FuncG([String, MaybeG Number], RecordInterface),
      default: (asAttribute, step = 1)->
        unless _.isNumber @[asAttribute]
          throw new Error "doc.attribute `#{asAttribute}` is not Number"
        @[asAttribute] -= step
        yield @save()

    @public @async increment: FuncG([String, MaybeG Number], RecordInterface),
      default: (asAttribute, step = 1)->
        unless _.isNumber @[asAttribute]
          throw new Error "doc.attribute `#{asAttribute}` is not Number"
        @[asAttribute] += step
        yield @save()

    @public @async toggle: FuncG(String, RecordInterface),
      default: (asAttribute)->
        unless _.isBoolean @[asAttribute]
          throw new Error "doc.attribute `#{asAttribute}` is not Boolean"
        @[asAttribute] = not @[asAttribute]
        yield @save()

    @public @async touch: FuncG([], RecordInterface),
      default: ->
        @updatedAt = new Date()
        yield @save()

    @public @async updateAttribute: FuncG([String, MaybeG AnyT], RecordInterface),
      default: (name, value)->
        @[name] = value
        yield @save()

    @public @async updateAttributes: FuncG(Object, RecordInterface),
      default: (aoAttributes)->
        for own vsAttrName, voAttrValue of aoAttributes
          @[vsAttrName] = voAttrValue
        yield @save()

    @public @async isNew: FuncG([], Boolean),
      default: ->
        return yes  unless @id?
        return not (yield @collection.includes @id)

    # TODO: надо реализовать, НО пока не понятно как перезагрузить все атрибуты этого же рекорда новыми значениями из базы данных?
    @public @async reload: FuncG([], RecordInterface),
      default: ->
        throw new Error 'not supported yet'
        yield return

    # TODO: не учтены установки значений, которые раньше не были установлены
    @public @async changedAttributes: FuncG([], DictG String, Array),
      default: ->
        vhResult = {}
        for own vsAttrName, { transform } of @constructor.attributes
          voOldValue = @[ipoInternalRecord]?[vsAttrName]
          voNewValue = transform.call(@constructor).objectize @[vsAttrName]
          unless _.isEqual voNewValue, voOldValue
            vhResult[vsAttrName] = [voOldValue, voNewValue]
        yield return vhResult

    @public @async resetAttribute: FuncG(String, NilT),
      default: (asAttribute)->
        if @[ipoInternalRecord]?
          if (attrConf = @constructor.attributes[asAttribute])?
            { transform } = attrConf
            @[asAttribute] = yield transform.call(@constructor).normalize @[ipoInternalRecord][asAttribute]
        yield return

    @public @async rollbackAttributes: Function,
      default: ->
        if @[ipoInternalRecord]?
          for own vsAttrName, { transform } of @constructor.attributes
            voOldValue = @[ipoInternalRecord][vsAttrName]
            @[vsAttrName] = yield transform.call(@constructor).normalize voOldValue
        yield return

    @public @static @async restoreObject: FuncG([SubsetG(Module), Object], RecordInterface),
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          Facade = Module::ApplicationFacade ? Module::Facade
          facade = Facade.getInstance replica.multitonKey
          collection = facade.retrieveProxy replica.collectionName
          if replica.isNew
            # NOTE: оставлено временно для обратной совместимости. Понятно что в будущем надо эту ветку удалить.
            instance = yield collection.build replica.attributes
          else
            instance = yield collection.find replica.id
          yield return instance
        else
          return yield @super Module, replica

    @public @static @async replicateObject: FuncG(RecordInterface, Object),
      default: (instance)->
        replica = yield @super instance
        ipsMultitonKey = Symbol.for '~multitonKey'
        replica.multitonKey = instance.collection[ipsMultitonKey]
        replica.collectionName = instance.collection.getProxyName()
        replica.isNew = yield instance.isNew()
        if replica.isNew
          throw new Error "Replicating record is `new`. It must be seved previously"
        else
          changedAttributes = yield instance.changedAttributes()
          if (changedKeys = Object.keys changedAttributes).length > 0
            throw new Error "Replicating record has changedAttributes #{changedKeys}"
          replica.id = instance.id
        yield return replica

    @public init: FuncG([Object, CollectionInterface], NilT),
      default: (aoProperties, aoCollection) ->
        @super arguments...
        @collection = aoCollection

        for own vsAttrName, voAttrValue of aoProperties
          @[vsAttrName] = voAttrValue
        return

    @public toJSON: FuncG([], Object), { default: -> @constructor.objectize @ }


    @initialize()
