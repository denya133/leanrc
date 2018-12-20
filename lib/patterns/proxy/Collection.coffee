

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
  {
    AnyT, NilT
    FuncG, SubsetG, MaybeG, UnionG, ListG, InterfaceG
    CollectionInterface, RecordInterface, CursorInterface
    SerializerInterface, ObjectizerInterface
    ConfigurableMixin
    Serializer, Objectizer
    Utils: { _, inflect }
  } = Module::

  class Collection extends Module::Proxy
    @inheritProtected()
    @include ConfigurableMixin
    @implements CollectionInterface
    @module Module

    @public delegate: SubsetG(RecordInterface),
      get: ->
        delegate = @getData()?.delegate
        UnionG(String, Function, SubsetG RecordInterface) delegate
        if _.isString delegate
          delegate = (@ApplicationModule.NS ? @ApplicationModule::)[delegate]
        else unless /Migration$|Record$/.test delegate.name
          delegate = delegate?()
        delegate
    @public serializer: MaybeG SerializerInterface
    @public objectizer: MaybeG ObjectizerInterface

    @public collectionName: FuncG([], String),
      default: ->
        firstClassName = _.first _.remove @delegate.parentClassNames(), (name)->
          not /Mixin$|Interface$|^CoreObject$|^Record$/.test name
        inflect.pluralize inflect.underscore firstClassName.replace /Record$/, ''

    @public collectionPrefix: FuncG([], String),
      default: ->
        "#{inflect.underscore @Module.name}_"

    @public collectionFullName: FuncG([MaybeG String], String),
      default: (asName = null)->
        "#{@collectionPrefix()}#{asName ? @collectionName()}"

    @public recordHasBeenChanged: FuncG([String, Object]),
      default: (asType, aoData)->
        @sendNotification Module::RECORD_CHANGED, aoData, asType
        return

    @public @async generateId: FuncG([], UnionG String, Number, NilT),
      default: -> yield return

    @public @async build: FuncG(Object, RecordInterface),
      default: (properties)->
        return yield @objectizer.recoverize @delegate, properties

    @public @async create: FuncG(Object, RecordInterface),
      default: (properties)->
        voRecord = yield @build properties
        return yield voRecord.save()

    @public @async push: FuncG(RecordInterface, RecordInterface),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async delete: FuncG([UnionG String, Number]),
      default: (id)->
        voRecord = yield @find id
        yield voRecord.delete()
        yield return

    @public @async destroy: FuncG([UnionG String, Number]),
      default: (id)->
        voRecord = yield @find id
        yield voRecord.destroy()
        yield return

    @public @async remove: FuncG([UnionG String, Number]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async find: FuncG([UnionG String, Number], MaybeG RecordInterface),
      default: (id)-> return yield @take id

    @public @async findMany: FuncG([ListG UnionG String, Number], CursorInterface),
      default: (ids)-> return yield @takeMany ids

    @public @async take: FuncG([UnionG String, Number], MaybeG RecordInterface),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async takeMany: FuncG([ListG UnionG String, Number], CursorInterface),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async takeAll: FuncG([], CursorInterface),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async update: FuncG([UnionG(String, Number), Object], RecordInterface),
      default: (id, properties)->
        properties.id = id
        existedRecord = yield @find id
        receivedRecord = yield @objectizer.recoverize @delegate, properties
        for own key of properties
          existedRecord[key] = receivedRecord[key]
        return yield existedRecord.save()

    @public @async override: FuncG([UnionG(String, Number), RecordInterface], RecordInterface),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async clone: FuncG(RecordInterface, RecordInterface),
      default: (aoRecord)->
        vhAttributes = {}
        vlAttributes = Object.keys @delegate.attributes
        for key in vlAttributes
          vhAttributes[key] = aoRecord[key]
        voRecord = @delegate.new vhAttributes, @
        voRecord.id = yield @generateId()
        yield return voRecord

    @public @async copy: FuncG(RecordInterface, RecordInterface),
      default: (aoRecord)->
        voRecord = yield @clone aoRecord
        yield voRecord.save()
        yield return voRecord

    @public @async includes: FuncG([UnionG String, Number], Boolean),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async length: FuncG([], Number),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async normalize: FuncG(AnyT, RecordInterface),
      default: (ahData)->
        return yield @serializer.normalize @delegate, ahData

    @public @async serialize: FuncG(RecordInterface, AnyT),
      default: (aoRecord, ahOptions)->
        return yield @serializer.serialize aoRecord, ahOptions

    @public init: FuncG([String, MaybeG InterfaceG {
      delegate: UnionG String, Function, SubsetG RecordInterface
      serializer: MaybeG UnionG String, Function, SubsetG Serializer
      objectizer: MaybeG UnionG String, Function, SubsetG Objectizer
    }]),
      default: (args...)->
        @super args...
        serializer = @getData()?.serializer
        objectizer = @getData()?.objectizer
        vcSerializer = unless serializer?
          Serializer
        else if _.isString serializer
          (
            @ApplicationModule.NS ? @ApplicationModule::
          )[serializer]
        else unless /Serializer$/.test serializer.name
          serializer?()
        else
          serializer
        vcObjectizer = unless objectizer?
          Objectizer
        else if _.isString objectizer
          (
            @ApplicationModule.NS ? @ApplicationModule::
          )[objectizer]
        else unless /Objectizer$/.test objectizer.name
          objectizer?()
        else
          objectizer

        @serializer = vcSerializer.new @
        @objectizer = vcObjectizer.new @
        return


    @initialize()
