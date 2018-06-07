

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
    Utils: { _, inflect }
  } = Module::

  class Collection extends Module::Proxy
    @inheritProtected()
    # @implements Module::CollectionInterface
    @include Module::ConfigurableMixin
    @module Module

    @public delegate: Module::Class,
      get: ->
        delegate = @getData()?.delegate
        if _.isString delegate
          delegate = (@ApplicationModule.NS ? @ApplicationModule::)[delegate]
        else unless /Migration$|Record$/.test delegate.name
          delegate = delegate?()
        delegate
    @public serializer: Module::SerializerInterface
    @public objectizer: Module::ObjectizerInterface

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


    @public @async generateId: Function,
      default: -> yield return


    @public @async build: Function,
      default: (properties)->
        return yield @objectizer.recoverize @delegate, properties

    @public @async create: Function,
      default: (properties)->
        voRecord = yield @build properties
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

    @public @async update: Function,
      default: (id, properties)->
        properties.id = id
        voRecord = yield @objectizer.recoverize @delegate, properties
        return yield voRecord.save()

    @public @async clone: Function,
      default: (aoRecord)->
        vhAttributes = {}
        vlAttributes = Object.keys @delegate.attributes
        for key in vlAttributes
          vhAttributes[key] = aoRecord[key]
        voRecord = @delegate.new vhAttributes, @
        voRecord.id = yield @generateId()
        yield return voRecord

    @public @async copy: Function,
      default: (aoRecord)->
        voRecord = yield @clone aoRecord
        yield voRecord.save()
        return voRecord

    @public @async normalize: Function,
      default: (ahData)->
        return yield @serializer.normalize @delegate, ahData

    @public @async serialize: Function,
      default: (aoRecord, ahOptions)->
        return yield @serializer.serialize aoRecord, ahOptions

    @public init: Function,
      default: (args...)->
        @super args...
        serializer = @getData()?.serializer
        objectizer = @getData()?.objectizer
        vcSerializer = unless serializer?
          Module::Serializer
        else if _.isString serializer
          (
            @ApplicationModule.NS ? @ApplicationModule::
          )[serializer]
        else unless /Serializer$/.test serializer.name
          serializer?()
        else
          serializer
        vcObjectizer = unless objectizer?
          Module::Objectizer
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
        @


  Collection.initialize()
