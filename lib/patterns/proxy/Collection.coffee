

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


    @public @async generateId: Function,
      default: -> yield return


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

    @public @async update: Function,
      default: (id, properties)->
        voRecord = yield @find id
        yield voRecord.updateAttributes properties
        return voRecord

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
