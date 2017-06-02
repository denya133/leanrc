inflect = do require 'i'
_ = require 'lodash'


###
```coffee
# in application when its need

Module = require 'Module'
ArangoExtension = require 'leanrc-arango-extension'

# example of concrete application collection for instantuate it in PrepareModelCommand
module.exports = (App)->
  class App::ArangoCollection extends Module::Collection
    @include ArangoExtension::ArangoCollectionMixin
    #... some other definitions

  return App::ArangoCollection.initialize()
```

```coffee
module.exports = (App)->
  App::PrepareModelCommand extends Module::SimpleCommand
    @public execute: Function,
      default: ->
        #...
        @facade.registerProxy App::ArangoCollection.new 'CucumbersCollection',
          # какие-то конфиги
        #...
```
###


module.exports = (Module)->
  class Collection extends Module::Proxy
    @inheritProtected()
    @implements Module::CollectionInterface
    @include Module::ConfigurableMixin
    @module Module

    @public delegate: Module::Class,
      get: (delegate)->
        delegate ? @getData()?.delegate
    @public serializer: Module::SerializerInterface

    @public collectionName: Function,
      default: ->
        firstClassName = _.first _.remove @delegate.parentClassNames(), (name)->
          not /Mixin$|Interface$|^CoreObject$|^Record$/.test name
        inflect.pluralize inflect.underscore firstClassName.replace /Record$/, ''

    @public collectionPrefix: Function,
      default: ->
        "#{inflect.underscore @Module.name}_"

    @public collectionFullName: Function,
      default: (asName = null)->
        "#{@collectionPrefix()}#{asName ? @collectionName()}"

    @public recordHasBeenChanged: Function,
      default: (aoType, aoData)->
        @sendNotification Module::RECORD_CHANGED, aoData, aoType
        return
    # TODO: надо перенести в Record в виде статических методов, т.к. в Рекорды создаются на все сущности в виде классов, а Collection создается в приложении 1-3 раза, а потом уже создаются его инстансы с разными именами и разными делегатами (Рекордами)
    @public customFilters: Object, # возвращает установленные кастомные фильтры с учетом наследования
      default: {}
      get: (__customFilters)->
        AbstractClass = @
        fromSuper = if AbstractClass.__super__?
          AbstractClass.__super__.constructor.customFilters
        __customFilters[AbstractClass.name] ?= do ->
          Module::Utils.extend {}
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
        @delegate.new properties, @

    @public @async create: Function,
      default: (properties)->
        voRecord = @build properties
        yield voRecord.save()

    @public @async delete: Function,
      default: (id)->
        voRecord = yield @find id
        yield voRecord.delete()
        return voRecord

    @public @async destroy: Function,
      default: (id)->
        voRecord = yield @find id
        yield voRecord.destroy()
        return

    @public @async find: Function,
      default: (id)->
        yield @take id

    @public @async findMany: Function,
      default: (ids)->
        yield @takeMany ids

    @public @async replace: Function,
      default: (id, properties)->
        voRecord = yield @find id
        yield voRecord.updateAttributes properties # ????????????
        return voRecord

    @public @async update: Function,
      default: (id, properties)->
        voRecord = yield @find id
        yield voRecord.updateAttributes properties
        return voRecord

    @public clone: Function,
      default: (aoRecord)->
        vhAttributes = {}
        vlAttributes = Object.keys @delegate.attributes
        for key in vlAttributes
          vhAttributes[key] = aoRecord[key]
        voRecord = @delegate.new vhAttributes, @
        voRecord.id = @generateId()
        return voRecord

    @public @async copy: Function,
      default: (aoRecord)->
        voRecord = @clone aoRecord
        yield voRecord.save()
        return voRecord

    @public normalize: Function,
      default: (ahData)->
        @serializer.normalize @delegate, ahData

    @public serialize: Function,
      default: (aoRecord, ahOptions)->
        @serializer.serialize aoRecord, ahOptions

    @public init: Function,
      default: (args...)->
        @super args...
        vcSerializer = @getData()?.serializer ? Module::Serializer
        @serializer = vcSerializer.new @
        @


  Collection.initialize()
