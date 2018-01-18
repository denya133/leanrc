
###
for example

```coffee
module.exports = (Module)->
  {
    Collection
    QueryableCollectionMixin
    ArangoCollectionMixin
    IterableMixin
    GenerateAutoincrementIdMixin
  } = Module::

  class MainCollection extends Collection
    @inheritProtected()
    @include QueryableCollectionMixin
    @include ArangoCollectionMixin
    @include IterableMixin
    @include GenerateAutoincrementIdMixin
    @module Module


  MainCollection.initialize()
```
###

module.exports = (Module)->
  {
    Collection
    Query
  } = Module::

  Module.defineMixin 'GenerateAutoincrementIdMixin', (BaseClass = Collection) ->
    class extends BaseClass
      @inheritProtected()

      @public @async generateId: Function,
        default: ->
          voQuery = Query.new()
            .forIn '@doc': @collectionFullName()
            .max '@doc.id'
          maxId = yield (yield @query voQuery).first()
          maxId ?= 0
          yield return ++maxId


      @initializeMixin()
