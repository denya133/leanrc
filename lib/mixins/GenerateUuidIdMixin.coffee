
###
for example

```coffee
module.exports = (Module)->
  {
    Collection
    QueryableCollectionMixin
    ArangoCollectionMixin
    IterableMixin
    GenerateUuidIdMixin
  } = Module::

  class MainCollection extends Collection
    @inheritProtected()
    @include QueryableCollectionMixin
    @include ArangoCollectionMixin
    @include IterableMixin
    @include GenerateUuidIdMixin
    @module Module


  MainCollection.initialize()
```
###

module.exports = (Module)->
  {
    FuncG
    Collection, Mixin
    Utils: { uuid }
  } = Module::

  Module.defineMixin Mixin 'GenerateUuidIdMixin', (BaseClass = Collection) ->
    class extends BaseClass
      @inheritProtected()

      @public @async generateId: FuncG([], String),
        default: -> yield return uuid.v4()


      @initializeMixin()
