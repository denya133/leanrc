
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
    FuncG
    Collection, Mixin, Query
  } = Module::

  Module.defineMixin Mixin 'GenerateAutoincrementIdMixin', (BaseClass = Collection) ->
    class extends BaseClass
      @inheritProtected()

      @public @async generateId: FuncG([], Number),
        default: ->
          voQuery = Query.new()
            .forIn '@doc': @collectionFullName()
            .max '@doc.id'
          maxId = yield (yield @query voQuery).first()
          maxId ?= 0
          yield return ++maxId


      @initializeMixin()
