
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

  Module.defineMixin Collection, (BaseClass) ->
    class GenerateAutoincrementIdMixin extends BaseClass
      @inheritProtected()

      @public @async generateId: Function,
        default: ->
          voQuery = Query.new()
            .forIn '@doc': @collectionFullName()
            .max '@doc.id'
          minId = yield (yield @query voQuery).first()
          minId ?= 0
          yield return minId++


    GenerateAutoincrementIdMixin.initializeMixin()
