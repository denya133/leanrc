
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
    Collection
    Utils: { uuid }
  } = Module::

  Module.defineMixin 'GenerateUuidIdMixin', (BaseClass = Collection) ->
    class extends BaseClass
      @inheritProtected()

      @public @async generateId: Function,
        default: -> yield return uuid.v4()


      @initializeMixin()
